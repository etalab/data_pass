import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.toggle_sticky_shadow_on_scroll()

    window.addEventListener('scroll', () => this.toggle_sticky_shadow_on_scroll())
  }

  disconnect () {
    window.removeEventListener('scroll', () => this.toggle_sticky_shadow_on_scroll())
  }

  toggle_sticky_shadow_on_scroll () {
    const threshold = this.element.offsetTop - window.innerHeight + this.element.offsetHeight

    if (window.scrollY > threshold) {
      this.element.classList.remove('sticky-shadow')
    } else {
      this.element.classList.add('sticky-shadow')
    }
  }
}
