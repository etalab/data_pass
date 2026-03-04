import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['section']
  static values = { blockName: String }

  connect () {
    const checkbox = this.blockCheckbox
    if (checkbox) {
      checkbox.addEventListener('change', this.updateVisibility.bind(this))
    }
    this.updateVisibility()
  }

  updateVisibility () {
    if (this.blockCheckbox?.checked) {
      this.sectionTarget.classList.remove('fr-hidden')
    } else {
      this.sectionTarget.classList.add('fr-hidden')
    }
  }

  get blockCheckbox () {
    return document.getElementById(`block_${this.blockNameValue}`)
  }
}
