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
    'srAnnouncement',
    'nativeSelect'
  ]

  static values = {
    name: String,
    placeholder: { type: String, default: 'Sélectionner une option' }
  }

  connect () {
    this.selectedValues = new Set()
    this.selectedLabels = new Map()
    this._initializeFromDOM()
    this._updateDisplay()
    this._handleClickOutside = this._handleClickOutside.bind(this)
    document.addEventListener('click', this._handleClickOutside, true)

    // Progressive enhancement: hide native select, show JS-powered component
    this._activateEnhancedMode()
  }

  _activateEnhancedMode () {
    if (this.hasNativeSelectTarget) {
      this.nativeSelectTarget.classList.add('fr-hidden')
      this.nativeSelectTarget.disabled = true
    }

    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove('dsfrx-multiselect--js-only')
    }
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
          this._close()
        } else if (!event.shiftKey && this._isLastToolbarElement(event.target)) {
          this._close()
        }
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
          event.preventDefault()
          this._focusToolbar()
        } else {
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
    const hasAnySelected = this._hasAnySelected()

    if (hasAnySelected) {
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

    options.forEach(li => {
      const label = li.dataset.label.toLowerCase()
      const matches = label.includes(searchText)
      li.classList.toggle('fr-hidden', !matches)
      if (matches) visibleCount++
    })

    groups.forEach(group => {
      const groupOptions = group.querySelectorAll('li[role="option"]:not(.fr-hidden)')
      group.classList.toggle('fr-hidden', groupOptions.length === 0)
    })

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle('fr-hidden', visibleCount > 0)
    }

    this._announceResults(visibleCount)
  }

  _announceResults (count) {
    if (!this.hasSrAnnouncementTarget) return

    this.srAnnouncementTarget.textContent = ''

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

    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ''
      this.handleSearch()
    }
  }

  _close () {
    this.dropdownTarget.classList.add('fr-hidden')
    this.dropdownTarget.setAttribute('aria-hidden', 'true')
    this.triggerTarget.setAttribute('aria-expanded', 'false')
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
    if (this._hasToolbar()) {
      this._focusToolbar()
    } else {
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

  _hasAnySelected () {
    return this.selectedValues.size > 0
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

    const hasAnySelected = this._hasAnySelected()
    this.selectAllLabelTarget.textContent = hasAnySelected ? 'Tout désélectionner' : 'Tout sélectionner'
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
