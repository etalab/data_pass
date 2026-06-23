import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['container', 'backdrop', 'title', 'closeButton']

  connect () {
    this.isOpen = false
  }

  disconnect () {
    this.unlockBodyScroll()
  }

  open (event) {
    const title = event.params.title
    if (title) this.titleTarget.textContent = title

    this.triggerButton = event.currentTarget
    if (this.isOpen) return

    this.isOpen = true
    this.show()
  }

  close () {
    if (!this.isOpen) return

    this.isOpen = false
    this.hide()
  }

  show () {
    this.containerTarget.removeAttribute('inert')
    this.containerTarget.setAttribute('aria-hidden', 'false')
    this.containerTarget.classList.add('side-panel-container--open')
    this.lockBodyScroll()
    this.updateTriggerButtons(true)
    this.closeButtonTarget.focus()
  }

  hide () {
    this.containerTarget.setAttribute('inert', '')
    this.containerTarget.setAttribute('aria-hidden', 'true')
    this.containerTarget.classList.remove('side-panel-container--open')
    this.unlockBodyScroll()
    this.updateTriggerButtons(false)
    this.triggerButton?.focus()
    this.triggerButton = null
  }

  lockBodyScroll () {
    document.body.style.overflow = 'hidden'
  }

  unlockBodyScroll () {
    document.body.style.overflow = ''
  }

  updateTriggerButtons (isOpen) {
    this.element.querySelectorAll('[data-action*="side-panel#open"]').forEach((button) => {
      button.setAttribute('aria-expanded', String(isOpen && button === this.triggerButton))
    })
  }
}
