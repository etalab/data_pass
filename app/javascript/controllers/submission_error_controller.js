import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['alert']

  connect () {
    this.alertTarget.hidden = true
  }

  check (event) {
    if (event.detail.fetchResponse.statusCode < 500) return

    event.preventDefault()
    this.show()
  }

  show () {
    this.alertTarget.hidden = false
    this.alertTarget.focus()
  }
}
