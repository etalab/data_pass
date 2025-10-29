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

    this.showNotification(firstElement)

    event.target.classList.add('fr-hidden')
  }

  showNotification (firstElement) {
    if (this.hasNotificationTarget) {
      const message = this.notificationTarget.getAttribute('data-message') || 'Vos informations ont été remplies automatiquement'

      setTimeout(() => {
        this.notificationTarget.innerHTML = `
          <div class="fr-alert fr-alert--success fr-alert--sm fr-my-2w">
            <p class="fr-alert__title">${message}</p>
          </div>
        `
        this.notificationTarget.focus()

        if (firstElement) {
          setTimeout(() => {
            firstElement.focus()
          }, 5000)
        }

        setTimeout(() => {
          this.hideNotification()
        }, 5000)
      }, 100)
    }
  }

  hideNotification () {
    if (this.hasNotificationTarget) {
      this.notificationTarget.textContent = ''
    }
  }
}
