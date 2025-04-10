import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['select', 'toggle']
  static values = {
    showOn: Array
  }

  connect () {
    this.toggleVisibility()
  }

  toggleVisibility () {
    const selectedValue = this.selectTarget.value
    const shouldShow = this.showOnValue.includes(selectedValue)
    this.toggleTarget.classList.toggle('fr-hidden', !shouldShow)
  }

  change () {
    this.toggleVisibility()
  }
}
