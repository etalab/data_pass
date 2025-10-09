import { Controller } from '@hotwired/stimulus'

// Usage:
// <div data-controller="modal" data-modal-open-value="false">
//   <button data-action="click->modal#open">Open Modal</button>
//   <button data-action="click->modal#close">Close Modal</button>
// </div>
export default class extends Controller {
  static values = {
    open: { type: Boolean, default: false }
  }

  connect () {
    if (this.openValue) {
      this.open()
    }
  }

  open (event) {
    if (event) {
      event.preventDefault()
    }
    this.element.classList.add('fr-modal--opened')
    document.body.classList.add('fr-modal-opened')
  }

  close (event) {
    if (event) {
      event.preventDefault()
    }
    this.element.classList.remove('fr-modal--opened')
    document.body.classList.remove('fr-modal-opened')

    // Remove turbo-frame content after animation
    setTimeout(() => {
      const frame = document.getElementById('modal')
      if (frame) {
        frame.innerHTML = ''
      }
    }, 300)
  }

  // Close modal when clicking outside
  handleClickOutside (event) {
    if (event.target === this.element) {
      this.close(event)
    }
  }

  // Close modal on escape key
  handleEscape (event) {
    if (event.key === 'Escape') {
      this.close(event)
    }
  }
}
