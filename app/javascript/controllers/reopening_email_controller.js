import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['checkbox', 'standard', 'reopening']

  toggle (event) {
    const showReopening = event.target.checked
    const shownTarget = showReopening ? this.reopeningTarget : this.standardTarget

    this.standardTarget.classList.toggle('fr-hidden', showReopening)
    this.reopeningTarget.classList.toggle('fr-hidden', !showReopening)
    this.checkboxTargets.forEach((checkbox) => { checkbox.checked = showReopening })

    shownTarget.querySelector('[data-reopening-email-target="checkbox"]').focus()
  }
}
