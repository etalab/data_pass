import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['value', 'justificationBlock']

  connect () {
    this.toggleJustificationBlock()

    this.valueTarget.addEventListener('change', () => {
      this.toggleJustificationBlock()
    })
  }

  toggleJustificationBlock () {
    if (this.valueTarget.value > 36) {
      this.justificationBlockTarget.classList.remove('fr-hidden')
    } else {
      this.justificationBlockTarget.classList.add('fr-hidden')
    }
  }
}
