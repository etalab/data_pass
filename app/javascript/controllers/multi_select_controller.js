import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['trigger', 'dropdown', 'label', 'optionsList', 'hiddenInputs', 'clearButton']
  static values = {
    name: String,
    placeholder: { type: String, default: 'Sélectionnez...' },
    allLabel: { type: String, default: 'Tous' }
  }

  connect () {
    this.selectedValues = new Set()
    this.selectedLabels = new Map()
    this._initializeFromParams()
    this._updateDisplay()
    this._handleClickOutside = this._handleClickOutside.bind(this)
    document.addEventListener('click', this._handleClickOutside, true)
  }

  disconnect () {
    document.removeEventListener('click', this._handleClickOutside, true)
  }

  toggle (event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.dropdownTarget.classList.contains('fr-hidden')) {
      this._open()
      this._focusFirstOption()
    } else {
      this._close()
    }
  }

  handleTriggerKeydown (event) {
    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowUp':
      case 'Enter':
      case ' ':
        event.preventDefault()
        if (this.dropdownTarget.classList.contains('fr-hidden')) {
          this._open()
          this._focusFirstOption()
        }
        break
      case 'Escape':
        event.preventDefault()
        this._close()
        break
    }
  }

  handleOptionKeydown (event) {
    const options = this._getOptions()
    const currentIndex = options.indexOf(event.currentTarget)

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        if (currentIndex < options.length - 1) {
          options[currentIndex + 1].focus()
        }
        break
      case 'ArrowUp':
        event.preventDefault()
        if (currentIndex > 0) {
          options[currentIndex - 1].focus()
        } else {
          this.clearButtonTarget.focus()
        }
        break
      case 'Enter':
      case ' ':
        event.preventDefault()
        this.selectOption(event)
        break
      case 'Escape':
        event.preventDefault()
        this._close()
        this.triggerTarget.focus()
        break
      case 'Tab':
        this._close()
        break
    }
  }

  handleClearKeydown (event) {
    const options = this._getOptions()

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        if (options.length > 0) {
          options[0].focus()
        }
        break
      case 'ArrowUp':
        event.preventDefault()
        break
      case 'Enter':
      case ' ':
        event.preventDefault()
        this.clearAll(event)
        this.triggerTarget.focus()
        break
      case 'Escape':
        event.preventDefault()
        this._close()
        this.triggerTarget.focus()
        break
      case 'Tab':
        this._close()
        break
    }
  }

  selectOption (event) {
    event.preventDefault()
    event.stopPropagation()

    const value = event.currentTarget.dataset.multiSelectValueParam
    const label = event.currentTarget.dataset.multiSelectLabelParam

    if (this.selectedValues.has(value)) {
      this.selectedValues.delete(value)
      this.selectedLabels.delete(value)
      event.currentTarget.classList.remove('selected')
      event.currentTarget.setAttribute('aria-selected', 'false')
    } else {
      this.selectedValues.add(value)
      this.selectedLabels.set(value, label)
      event.currentTarget.classList.add('selected')
      event.currentTarget.setAttribute('aria-selected', 'true')
    }

    this._updateDisplay()
    this._updateHiddenInputs()
    this._dispatchChange()
  }

  clearAll (event) {
    event.preventDefault()
    event.stopPropagation()

    this.selectedValues.clear()
    this.selectedLabels.clear()

    this.optionsListTarget.querySelectorAll('li').forEach(li => {
      li.classList.remove('selected')
      li.setAttribute('aria-selected', 'false')
    })

    this._updateDisplay()
    this._updateHiddenInputs()
    this._close()
    this._dispatchChange()
  }

  _open () {
    this.dropdownTarget.classList.remove('fr-hidden')
    this.triggerTarget.setAttribute('aria-expanded', 'true')
    this.dropdownTarget.setAttribute('aria-hidden', 'false')
  }

  _close () {
    this.dropdownTarget.classList.add('fr-hidden')
    this.triggerTarget.setAttribute('aria-expanded', 'false')
    this.dropdownTarget.setAttribute('aria-hidden', 'true')
  }

  _handleClickOutside (event) {
    if (!this.element.contains(event.target)) {
      this._close()
    }
  }

  _updateDisplay () {
    if (this.selectedValues.size === 0) {
      this.labelTarget.textContent = this.allLabelValue
      this.labelTarget.classList.remove('has-selection')
      this.clearButtonTarget.classList.add('active')
    } else if (this.selectedValues.size === 1) {
      const label = Array.from(this.selectedLabels.values())[0]
      this.labelTarget.textContent = label
      this.labelTarget.classList.add('has-selection')
      this.clearButtonTarget.classList.remove('active')
    } else {
      this.labelTarget.textContent = `${this.selectedValues.size} sélectionnés`
      this.labelTarget.classList.add('has-selection')
      this.clearButtonTarget.classList.remove('active')
    }
  }

  _updateHiddenInputs () {
    this.hiddenInputsTarget.innerHTML = ''

    this.selectedValues.forEach(value => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = this.nameValue
      input.value = value
      this.hiddenInputsTarget.appendChild(input)
    })
  }

  _initializeFromParams () {
    this.optionsListTarget.querySelectorAll('li[data-preselected="true"]').forEach(li => {
      const value = li.dataset.multiSelectValueParam
      const label = li.dataset.multiSelectLabelParam
      this.selectedValues.add(value)
      this.selectedLabels.set(value, label)
      li.classList.add('selected')
      li.setAttribute('aria-selected', 'true')
    })
  }

  _dispatchChange () {
    this.element.dispatchEvent(new Event('input', { bubbles: true }))
  }

  _getOptions () {
    return Array.from(this.optionsListTarget.querySelectorAll('li[role="option"]'))
  }

  _focusFirstOption () {
    this.clearButtonTarget.focus()
  }
}
