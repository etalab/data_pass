import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['liveRegion', 'message', 'frame']

  connect () {
    this.boundAnnounce = this.announce.bind(this)
    this.frameTarget.addEventListener('turbo:frame-load', this.boundAnnounce)
  }

  disconnect () {
    this.frameTarget.removeEventListener('turbo:frame-load', this.boundAnnounce)
  }

  announce () {
    if (!this.hasMessageTarget || !this.hasLiveRegionTarget) {
      return
    }

    const message = this.messageTarget.textContent.trim()

    if (message === this.liveRegionTarget.textContent.trim()) {
      return
    }

    this.liveRegionTarget.textContent = message
  }
}
