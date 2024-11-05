import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['checkbox', 'fieldset']
  static classes = ['hidden']

  connect () {
    this.showFieldset()
    this.checkboxTarget.addEventListener('change', this.showFieldset.bind(this))
  }

  show () {
    this.fieldsetTarget.classList.remove(this.hiddenClass)
  }

  hide () {
    this.fieldsetTarget.classList.add(this.hiddenClass)
  }

  showFieldset () {
    if (this.checkboxTarget.checked) {
      this.show()
    } else {
      this.hide()
    }
  }
}
