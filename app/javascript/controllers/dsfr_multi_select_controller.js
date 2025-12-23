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
    'checkbox',
    'srAnnouncement'
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
      this._focusOnOpen()
    }
  }

  handleTriggerKeydown (event) {
    switch (event.key) {
      case 'ArrowDown':
      case 'Enter':
      case ' ':
        event.preventDefault()
        if (!this._isOpen()) {
          this._open()
          this._focusOnOpen()
        }
        break
      case 'ArrowUp':
        event.preventDefault()
        if (!this._isOpen()) {
          this._open()
          this._focusOnOpen()
        }
        break
      case 'Escape':
        event.preventDefault()
        if (this._isOpen()) {
          this._close()
        }
        break
    }
  }

  handleToolbarKeydown (event) {
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this._focusFirstOption()
        break
      case 'Escape':
        event.preventDefault()
        this._close()
        this.triggerTarget.focus()
        break
      case 'Tab':
        if (event.shiftKey && this._isFirstToolbarElement(event.target)) {
          // Shift+Tab on first element: close and go back to trigger
          this._close()
        } else if (!event.shiftKey && this._isLastToolbarElement(event.target)) {
          // Tab on last element: close dropdown
          this._close()
        }
        // Otherwise let natural Tab navigation happen within toolbar
        break
    }
  }

  _isFirstToolbarElement (element) {
    if (this.hasSelectAllButtonTarget && element === this.selectAllButtonTarget) {
      return true
    }
    if (!this.hasSelectAllButtonTarget && this.hasSearchInputTarget && element === this.searchInputTarget) {
      return true
    }
    return false
  }

  _isLastToolbarElement (element) {
    if (this.hasSearchInputTarget && element === this.searchInputTarget) {
      return true
    }
    if (!this.hasSearchInputTarget && this.hasSelectAllButtonTarget && element === this.selectAllButtonTarget) {
      return true
    }
    return false
  }

  handleOptionKeydown (event) {
    const options = this._getVisibleOptions()
    const currentIndex = options.indexOf(event.currentTarget)

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        if (currentIndex < options.length - 1) {
          this._setFocusOnOption(options[currentIndex + 1])
        } else {
          // Loop to first option
          this._setFocusOnOption(options[0])
        }
        break
      case 'ArrowUp':
        event.preventDefault()
        if (currentIndex > 0) {
          this._setFocusOnOption(options[currentIndex - 1])
        } else {
          // Go back to toolbar if exists, otherwise loop to last option
          if (this._hasToolbar()) {
            this._focusToolbar()
          } else {
            this._setFocusOnOption(options[options.length - 1])
          }
        }
        break
      case 'Home':
        event.preventDefault()
        if (options.length > 0) {
          this._setFocusOnOption(options[0])
        }
        break
      case 'End':
        event.preventDefault()
        if (options.length > 0) {
          this._setFocusOnOption(options[options.length - 1])
        }
        break
      case 'Enter':
        event.preventDefault()
        this.selectOption(event)
        break
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
        if (event.shiftKey && this._hasToolbar()) {
          // Shift+Tab: go back to toolbar
          event.preventDefault()
          this._focusToolbar()
        } else {
          // Tab: close dropdown
          this._close()
        }
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
      li.setAttribute('aria-checked', 'false')
      if (checkbox) checkbox.checked = false
    } else {
      this.selectedValues.add(value)
      this.selectedLabels.set(value, label)
      li.classList.add('selected')
      li.setAttribute('aria-checked', 'true')
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
        li.setAttribute('aria-checked', 'false')
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
        li.setAttribute('aria-checked', 'true')
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
    const groups = this.listboxTarget.querySelectorAll('li[role="group"]')
    let visibleCount = 0

    // Filter options
    options.forEach(li => {
      const label = li.dataset.label.toLowerCase()
      const matches = label.includes(searchText)
      li.classList.toggle('fr-hidden', !matches)
      if (matches) visibleCount++
    })

    // Show/hide groups based on whether they have visible options
    groups.forEach(group => {
      const groupOptions = group.querySelectorAll('li[role="option"]:not(.fr-hidden)')
      group.classList.toggle('fr-hidden', groupOptions.length === 0)
    })

    // Show/hide empty state
    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle('fr-hidden', visibleCount > 0)
    }

    // Announce results to screen readers
    this._announceResults(visibleCount)
  }

  _announceResults (count) {
    if (!this.hasSrAnnouncementTarget) return

    // Clear previous announcement
    this.srAnnouncementTarget.textContent = ''

    // Small delay to ensure screen readers pick up the change
    setTimeout(() => {
      if (count === 0) {
        this.srAnnouncementTarget.textContent = 'Aucun résultat disponible'
      } else if (count === 1) {
        this.srAnnouncementTarget.textContent = '1 résultat disponible'
      } else {
        this.srAnnouncementTarget.textContent = `${count} résultats disponibles`
      }
    }, 100)
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
    // Clear aria-activedescendant
    this.listboxTarget.removeAttribute('aria-activedescendant')
  }

  _isOpen () {
    return !this.dropdownTarget.classList.contains('fr-hidden')
  }

  _handleClickOutside (event) {
    if (!this.element.contains(event.target)) {
      this._close()
    }
  }

  _hasToolbar () {
    return this.hasSelectAllButtonTarget || this.hasSearchInputTarget
  }

  _focusOnOpen () {
    // If toolbar exists, focus on first toolbar element
    if (this._hasToolbar()) {
      this._focusToolbar()
    } else {
      // Focus on first selected option, or first option if none selected
      this._focusFirstSelectedOrFirstOption()
    }
  }

  _focusToolbar () {
    if (this.hasSelectAllButtonTarget) {
      this.selectAllButtonTarget.focus()
    } else if (this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
    }
  }

  _focusFirstOption () {
    const options = this._getVisibleOptions()
    if (options.length > 0) {
      this._setFocusOnOption(options[0])
    }
  }

  _focusFirstSelectedOrFirstOption () {
    const options = this._getVisibleOptions()
    if (options.length === 0) return

    // Find first selected option
    const firstSelected = options.find(opt => opt.classList.contains('selected'))
    if (firstSelected) {
      this._setFocusOnOption(firstSelected)
    } else {
      this._setFocusOnOption(options[0])
    }
  }

  _setFocusOnOption (optionElement) {
    if (!optionElement) return

    optionElement.focus()

    // Set aria-activedescendant on listbox
    const optionId = optionElement.getAttribute('id')
    if (optionId) {
      this.listboxTarget.setAttribute('aria-activedescendant', optionId)
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
