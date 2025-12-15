import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    applicantData: Object
  }

  static targets = ['notification']

  perform (event) {
    let firstElement = null

    ;['family_name', 'given_name', 'email', 'phone_number', 'job_title'].forEach((field) => {
      const element = this.element.querySelectorAll('[id$="_' + field + '"]')[0]

      if (element) {
        if (!firstElement) {
          firstElement = element
        }
        element.value = this.applicantDataValue[field]
        element.dispatchEvent(new Event('input', { bubbles: true }))
      }
    })

    this.showNotification(firstElement, event.target)
  }

  showNotification (firstElement, button) {
    if (this.hasNotificationTarget) {
      const message = this.notificationTarget.getAttribute('data-message') || 'Vos informations ont été remplies automatiquement'

      this.notificationTarget.innerHTML = `<p>${message}</p>`

      if (firstElement) {
        setTimeout(() => {
          firstElement.focus()
          button.classList.add('fr-hidden')
          this.hideNotification()
        }, 3500)
      }
    }
  }

  hideNotification () {
    if (this.hasNotificationTarget) {
      this.notificationTarget.textContent = ''
    }
  }
}
