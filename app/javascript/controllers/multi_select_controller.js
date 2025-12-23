import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['trigger', 'dropdown', 'label', 'optionsList', 'hiddenInputs']
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
    document.addEventListener('click', this._handleClickOutside)
  }

  disconnect () {
    document.removeEventListener('click', this._handleClickOutside)
  }

  toggle (event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.dropdownTarget.classList.contains('fr-hidden')) {
      this._open()
    } else {
      this._close()
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
    } else if (this.selectedValues.size === 1) {
      const label = Array.from(this.selectedLabels.values())[0]
      this.labelTarget.textContent = label
      this.labelTarget.classList.add('has-selection')
    } else {
      this.labelTarget.textContent = `${this.selectedValues.size} sélectionnés`
      this.labelTarget.classList.add('has-selection')
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
}

