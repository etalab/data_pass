import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['submit']
  static values = { changed: Boolean, preventSubmit: Boolean }

  connect () {
    this.submitTarget.disabled = true
  }

  submit (event) {
    if (!this.preventSubmitValue) { return }
    if (this.changedValue) { return }

    event.preventDefault()
  }

  update () {
    this.changedValue = true
    this._enableSubmitButton()
  }

  _enableSubmitButton () {
    if (this.changedValue) {
      this.submitTarget.disabled = false
    } else {
      this.submitTarget.disabled = true
    }
  }
}
