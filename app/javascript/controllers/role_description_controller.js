import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['select', 'description']
  static values = { descriptions: Object }

  update () {
    const description = this.descriptionsValue[this.selectTarget.value] || ''

    this.descriptionTarget.textContent = description
    this.descriptionTarget.hidden = description === ''
  }
}
