import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'container',
    'trigger',
    'dropdown',
    'label',
    'listbox',
    'toolbar',
    'selectAllButton',
    'selectAllLabel',
    'searchInput',
    'hiddenInputs',
    'emptyState',
    'checkbox'
  ]

  static values = {
    name: String,
    placeholder: { type: String, default: 'Sélectionner une option' },
    allLabel: { type: String, default: 'Tous' }
  }

  connect () {
    this.selectedValues = new Set()
    this.selectedLabels = new Map()
    this._initializeFromDOM()
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

    if (this._isOpen()) {
      this._close()
    } else {
      this._open()
      this._focusFirstFocusable()
    }
  }

  handleTriggerKeydown (event) {
    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowUp':
      case 'Enter':
      case ' ':
        event.preventDefault()
        if (!this._isOpen()) {
          this._open()
          this._focusFirstFocusable()
        }
        break
      case 'Escape':
        event.preventDefault()
        this._close()
        break
    }
  }

  handleToolbarKeydown (event) {
    const options = this._getVisibleOptions()

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        if (options.length > 0) {
          options[0].focus()
        }
        break
      case 'Escape':
        event.preventDefault()
        this._close()
        this.triggerTarget.focus()
        break
      case 'Tab':
        if (!event.shiftKey && options.length > 0) {
          event.preventDefault()
          options[0].focus()
        } else if (event.shiftKey) {
          this._close()
        }
        break
    }
  }

  handleOptionKeydown (event) {
    const options = this._getVisibleOptions()
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
          this._focusToolbar()
        }
        break
      case 'Home':
        event.preventDefault()
        if (options.length > 0) {
          options[0].focus()
        }
        break
      case 'End':
        event.preventDefault()
        if (options.length > 0) {
          options[options.length - 1].focus()
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

  selectOption (event) {
    event.preventDefault()
    event.stopPropagation()

    const li = event.currentTarget
    if (li.dataset.disabled === 'true') return

    const value = li.dataset.value
    const label = li.dataset.label
    const checkbox = li.querySelector('input[type="checkbox"]')

    if (this.selectedValues.has(value)) {
      this.selectedValues.delete(value)
      this.selectedLabels.delete(value)
      li.classList.remove('selected')
      li.setAttribute('aria-selected', 'false')
      if (checkbox) checkbox.checked = false
    } else {
      this.selectedValues.add(value)
      this.selectedLabels.set(value, label)
      li.classList.add('selected')
      li.setAttribute('aria-selected', 'true')
      if (checkbox) checkbox.checked = true
    }

    this._updateDisplay()
    this._updateHiddenInputs()
    this._updateSelectAllButton()
    this._dispatchChange()
  }

  toggleSelectAll (event) {
    event.preventDefault()
    event.stopPropagation()

    const enabledOptions = this._getEnabledOptions()
    const allSelected = this._areAllSelected()

    if (allSelected) {
      // Deselect all
      enabledOptions.forEach(li => {
        const value = li.dataset.value
        this.selectedValues.delete(value)
        this.selectedLabels.delete(value)
        li.classList.remove('selected')
        li.setAttribute('aria-selected', 'false')
        const checkbox = li.querySelector('input[type="checkbox"]')
        if (checkbox) checkbox.checked = false
      })
    } else {
      // Select all
      enabledOptions.forEach(li => {
        const value = li.dataset.value
        const label = li.dataset.label
        this.selectedValues.add(value)
        this.selectedLabels.set(value, label)
        li.classList.add('selected')
        li.setAttribute('aria-selected', 'true')
        const checkbox = li.querySelector('input[type="checkbox"]')
        if (checkbox) checkbox.checked = true
      })
    }

    this._updateDisplay()
    this._updateHiddenInputs()
    this._updateSelectAllButton()
    this._dispatchChange()
  }

  handleSearch () {
    const searchText = this.hasSearchInputTarget ? this.searchInputTarget.value.toLowerCase() : ''
    const options = this.listboxTarget.querySelectorAll('li[role="option"]')
    let visibleCount = 0

    options.forEach(li => {
      const label = li.dataset.label.toLowerCase()
      const matches = label.includes(searchText)
      li.classList.toggle('fr-hidden', !matches)
      if (matches) visibleCount++
    })

    // Show/hide empty state
    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle('fr-hidden', visibleCount > 0)
    }
  }

  _open () {
    this.dropdownTarget.classList.remove('fr-hidden')
    this.dropdownTarget.setAttribute('aria-hidden', 'false')
    this.triggerTarget.setAttribute('aria-expanded', 'true')

    // Reset search if present
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ''
      this.handleSearch()
    }
  }

  _close () {
    this.dropdownTarget.classList.add('fr-hidden')
    this.dropdownTarget.setAttribute('aria-hidden', 'true')
    this.triggerTarget.setAttribute('aria-expanded', 'false')
  }

  _isOpen () {
    return !this.dropdownTarget.classList.contains('fr-hidden')
  }

  _handleClickOutside (event) {
    if (!this.element.contains(event.target)) {
      this._close()
    }
  }

  _focusFirstFocusable () {
    // Focus search input if present, otherwise select all button, otherwise first option
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
    } else if (this.hasSelectAllButtonTarget) {
      this.selectAllButtonTarget.focus()
    } else {
      const options = this._getVisibleOptions()
      if (options.length > 0) {
        options[0].focus()
      }
    }
  }

  _focusToolbar () {
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
    } else if (this.hasSelectAllButtonTarget) {
      this.selectAllButtonTarget.focus()
    }
  }

  _getVisibleOptions () {
    return Array.from(this.listboxTarget.querySelectorAll('li[role="option"]:not(.fr-hidden)'))
  }

  _getEnabledOptions () {
    return Array.from(this.listboxTarget.querySelectorAll('li[role="option"]:not([data-disabled="true"])'))
  }

  _areAllSelected () {
    const enabledOptions = this._getEnabledOptions()
    return enabledOptions.every(li => this.selectedValues.has(li.dataset.value))
  }

  _updateDisplay () {
    if (this.selectedValues.size === 0) {
      this.labelTarget.textContent = this.placeholderValue
      this.labelTarget.classList.add('dsfrx-multiselect--placeholder')
    } else if (this.selectedValues.size === 1) {
      const label = Array.from(this.selectedLabels.values())[0]
      this.labelTarget.textContent = label
      this.labelTarget.classList.remove('dsfrx-multiselect--placeholder')
    } else {
      this.labelTarget.textContent = `${this.selectedValues.size} sélectionnés`
      this.labelTarget.classList.remove('dsfrx-multiselect--placeholder')
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

  _updateSelectAllButton () {
    if (!this.hasSelectAllLabelTarget) return

    const allSelected = this._areAllSelected()
    this.selectAllLabelTarget.textContent = allSelected ? 'Tout désélectionner' : 'Tout sélectionner'
  }

  _initializeFromDOM () {
    const options = this.listboxTarget.querySelectorAll('li[role="option"]')
    options.forEach(li => {
      if (li.classList.contains('selected')) {
        const value = li.dataset.value
        const label = li.dataset.label
        this.selectedValues.add(value)
        this.selectedLabels.set(value, label)
      }
    })
  }

  _dispatchChange () {
    this.element.dispatchEvent(new Event('input', { bubbles: true }))
    this.element.dispatchEvent(new Event('change', { bubbles: true }))
  }
}
