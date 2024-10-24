import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['value', 'justification']
  static values = { minimum: Number }

  connect () {
    this.toggleJustification()

    this.valueTarget.addEventListener('change', () => {
      this.toggleJustification()
    })
  }

  selectedValue () {
    return this.valueTarget.value
  }

  justificationTextarea () {
    return this.justificationTarget.querySelector('textarea')
  }

  toggleJustification () {
    if (this.selectedValue() > this.minimumValue) {
      this.justificationTarget.classList.remove('fr-hidden')
      this.justificationTextarea().required = true
    } else {
      this.justificationTarget.classList.add('fr-hidden')
      this.justificationTextarea().required = false
    }
  }
}
