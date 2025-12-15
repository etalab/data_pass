import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['item', 'button', 'emptyMessage']
  static values = {
    attribute: { type: String, default: 'data-filter-value' }
  }

  connect () {
    this._updateButtonStates()
  }

  filter (event) {
    const filterValue = event.params.value

    this.buttonTargets.forEach(button => {
      if (button.dataset.filterValueParam === filterValue) {
        button.setAttribute('aria-pressed', 'true')
      } else {
        button.setAttribute('aria-pressed', 'false')
      }
    })

    if (filterValue === 'all') {
      this._showAll()
    } else {
      this._filterByValue(filterValue)
    }

    this._updateEmptyMessage()
  }

  _showAll () {
    this.itemTargets.forEach(item => {
      item.classList.remove('fr-hidden')
    })
  }

  _filterByValue (value) {
    this.itemTargets.forEach(item => {
      const itemValue = item.getAttribute(this.attributeValue)

      if (itemValue === value) {
        item.classList.remove('fr-hidden')
      } else {
        item.classList.add('fr-hidden')
      }
    })
  }

  _updateEmptyMessage () {
    if (!this.hasEmptyMessageTarget) return

    const visibleItems = this.itemTargets.filter(item => !item.classList.contains('fr-hidden'))

    if (visibleItems.length === 0) {
      this.emptyMessageTarget.classList.remove('fr-hidden')
    } else {
      this.emptyMessageTarget.classList.add('fr-hidden')
    }
  }

  _updateButtonStates () {
    const allButton = this.buttonTargets.find(button => button.dataset.filterValueParam === 'all')
    if (allButton) {
      allButton.setAttribute('aria-pressed', 'true')
    }
  }
}
