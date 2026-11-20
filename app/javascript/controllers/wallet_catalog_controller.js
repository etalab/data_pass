import { Controller } from '@hotwired/stimulus'

const SEARCH_DELAY = 250

export default class extends Controller {
  static targets = ['search', 'frame', 'count', 'fallback']
  static values = { url: String }

  connect () {
    if (this.hasFallbackTarget) this.fallbackTarget.hidden = true
  }

  disconnect () {
    clearTimeout(this.timer)
  }

  search () {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.load(), SEARCH_DELAY)
  }

  load () {
    clearTimeout(this.timer)
    const url = new URL(this.urlValue, window.location.origin)
    const query = this.searchTarget.value.trim()
    if (query !== '') url.searchParams.set('q', query)
    this.frameTarget.src = url.toString()
  }

  frameLoaded () {
    const results = this.frameTarget.querySelector('[data-count-text]')
    if (results) this.countTarget.textContent = results.dataset.countText
  }

  ignoreEnter (event) {
    event.preventDefault()
    this.load()
  }
}
