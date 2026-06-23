import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'item', 'count', 'emptyMessage']

  filter () {
    const query = this._normalize(this.inputTarget.value)
    let visibleCount = 0

    this.itemTargets.forEach(item => {
      const match = !query || item.dataset.searchText.includes(query)
      item.classList.toggle('fr-hidden', !match)
      if (match) visibleCount++
    })

    this._updateCount(visibleCount)

    if (this.hasEmptyMessageTarget) {
      this.emptyMessageTarget.classList.toggle('fr-hidden', visibleCount > 0)
    }
  }

  _updateCount (count) {
    if (!this.hasCountTarget) return

    const templates = JSON.parse(this.countTarget.dataset.templates)
    const key = count === 0 ? 'zero' : count === 1 ? 'one' : 'other'
    this.countTarget.textContent = templates[key].replace('%{count}', count)
  }

  _normalize (text) {
    return text.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim()
  }
}
