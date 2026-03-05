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
    const visible = this.blockCheckbox?.checked
    this.sectionTarget.classList.toggle('fr-hidden', !visible)
    this.sectionTarget.querySelectorAll('input[type="checkbox"]').forEach(input => {
      input.disabled = !visible
    })
  }

  get blockCheckbox () {
    return document.getElementById(`block_${this.blockNameValue}`)
  }
}
