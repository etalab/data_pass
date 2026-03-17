import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['button', 'section']

  toggle () {
    const isHidden = this.sectionTarget.hidden
    this.sectionTarget.hidden = !isHidden
    this.buttonTarget.setAttribute('aria-expanded', String(isHidden))

    if (isHidden) {
      this.sectionTarget.querySelector('input, select, textarea')?.focus()
    }
  }

  close () {
    this.sectionTarget.hidden = true
    this.buttonTarget.setAttribute('aria-expanded', 'false')
    this.buttonTarget.focus()
  }
}
