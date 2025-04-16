import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['checkbox', 'element']
  static classes = ['hidden']

  connect () {
    this.showElement()
    this.checkboxTarget.addEventListener('change', this.showElement.bind(this))
  }

  show () {
    this.elementTarget.classList.remove(this.hiddenClass)
    this.elementTarget.disabled = false
  }

  hide () {
    this.elementTarget.classList.add(this.hiddenClass)
    this.elementTarget.disabled = true
  }

  showElement () {
    if (this.checkboxTarget.checked) {
      this.show()
    } else {
      this.hide()
    }
  }
}
