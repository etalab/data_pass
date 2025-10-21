import { Controller } from '@hotwired/stimulus'

/* global MutationObserver */

export default class extends Controller {
  static targets = ['container', 'content']
  static values = {
    defaultClasses: { type: String, default: 'fr-col-12 fr-col-md-8 fr-col-lg-6' }
  }

  connect () {
    this.boundApplySizeClasses = this.applySizeClasses.bind(this)

    this.contentTarget.addEventListener('turbo:frame-load', this.boundApplySizeClasses)

    this.observer = new MutationObserver(() => {
      this.applySizeClasses()
    })

    this.observer.observe(this.contentTarget, {
      childList: true,
      subtree: true
    })

    this.applySizeClasses()
  }

  disconnect () {
    this.contentTarget.removeEventListener('turbo:frame-load', this.boundApplySizeClasses)
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  applySizeClasses () {
    const sizeClasses = this.getSizeClasses()
    this.updateContainerClasses(sizeClasses)
  }

  getSizeClasses () {
    const firstChild = this.contentTarget.firstElementChild

    if (!firstChild) {
      return this.defaultClassesValue
    }

    const customClasses = firstChild.dataset.modalSizeClasses
    if (customClasses) {
      return customClasses
    }

    const modalSize = firstChild.dataset.modalSize
    if (modalSize) {
      return this.getPredefinedSizeClasses(modalSize)
    }

    const turboFrameCustomClasses = this.contentTarget.dataset.modalSizeClasses
    if (turboFrameCustomClasses) {
      return turboFrameCustomClasses
    }

    const turboFrameModalSize = this.contentTarget.dataset.modalSize
    if (turboFrameModalSize) {
      return this.getPredefinedSizeClasses(turboFrameModalSize)
    }

    return this.defaultClassesValue
  }

  getPredefinedSizeClasses (size) {
    const sizeMap = {
      small: 'fr-col-12 fr-col-md-6 fr-col-lg-4',
      medium: 'fr-col-12 fr-col-md-8 fr-col-lg-6',
      large: 'fr-col-12 fr-col-md-10 fr-col-lg-8',
      full: 'fr-col-12'
    }

    return sizeMap[size] || this.defaultClassesValue
  }

  updateContainerClasses (newClasses) {
    const currentClasses = this.containerTarget.className.split(' ').filter(cls => !cls.startsWith('fr-col'))
    const updatedClasses = [...currentClasses, ...newClasses.split(' ')]
    this.containerTarget.className = updatedClasses.join(' ')
  }
}
