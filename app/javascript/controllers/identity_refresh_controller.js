import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { panel: String }

  connect () {
    this.start = this.start.bind(this)
    this.end = this.end.bind(this)

    this.element.addEventListener('turbo:submit-start', this.start)
    this.element.addEventListener('turbo:submit-end', this.end)
  }

  disconnect () {
    this.element.removeEventListener('turbo:submit-start', this.start)
    this.element.removeEventListener('turbo:submit-end', this.end)
    this.stopWatchingFocus()
  }

  start () {
    this.focusedId = this.focusedIdInPanel()
    this.setBusy(true)
  }

  end () {
    this.setBusy(false)
    this.restoreFocusOnceReplaced()
  }

  setBusy (busy) {
    const panel = this.panel()
    if (!panel) return

    const status = this.status()
    if (busy && status) status.replaceChildren(this.loadingMessage(panel))

    panel.setAttribute('aria-busy', busy ? 'true' : 'false')
    panel.querySelectorAll('[data-identity-refresh-loader]').forEach((loader) => { loader.hidden = !busy })
  }

  loadingMessage (panel) {
    const loader = panel.querySelector('[data-identity-refresh-loader]')
    const message = document.createElement('p')
    message.className = 'fr-sr-only'
    message.textContent = loader ? loader.textContent.trim() : ''

    return message
  }

  focusedIdInPanel () {
    const panel = this.panel()
    const focused = document.activeElement

    return panel && focused && focused.id && panel.contains(focused) ? focused.id : null
  }

  restoreFocusOnceReplaced () {
    if (!this.focusedId) return

    const previous = document.getElementById(this.focusedId)
    this.stopWatchingFocus()
    this.observer = new window.MutationObserver(() => {
      const replaced = document.getElementById(this.focusedId)
      if (!replaced || replaced === previous) return

      replaced.focus()
      this.stopWatchingFocus()
    })
    this.observer.observe(document.body, { childList: true, subtree: true })
  }

  stopWatchingFocus () {
    if (this.observer) this.observer.disconnect()
    this.observer = null
  }

  panel () {
    return document.getElementById(this.panelValue)
  }

  status () {
    return document.getElementById('wallet-identity-status')
  }
}
