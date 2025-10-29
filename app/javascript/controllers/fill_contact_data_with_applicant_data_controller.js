import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    applicantData: Object
  }

  static targets = ['notification']

  perform (event) {
    ['family_name', 'given_name', 'email', 'phone_number', 'job_title'].forEach((field) => {
      const element = this.element.querySelectorAll('[id$="_' + field + '"]')[0]

      if (element) {
        element.value = this.applicantDataValue[field]
        element.dispatchEvent(new Event('input', { bubbles: true }))
      }
    })

    this.showNotification()

    event.srcElement.classList.add('fr-hidden')
  }

  showNotification () {
    if (this.hasNotificationTarget) {
      const message = this.notificationTarget.getAttribute('data-message') || 'Vos informations ont été remplies automatiquement'

      this.notificationTarget.innerHTML = `
        <div class="fr-alert fr-alert--success fr-my-2w">
          <p class="fr-alert__title">${message}</p>
        </div>
      `

      setTimeout(() => {
        this.notificationTarget.focus()
      }, 100)

      setTimeout(() => {
        this.hideNotification()
      }, 5000)
    }
  }

  hideNotification () {
    if (this.hasNotificationTarget) {
      this.notificationTarget.innerHTML = ''
    }
  }
}
