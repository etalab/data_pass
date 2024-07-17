import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    applicantData: Object
  }

  perform (event) {
    ['family_name', 'given_name', 'email', 'phone_number', 'job_title'].forEach((field) => {
      const element = this.element.querySelectorAll('[id$="_' + field + '"]')[0]

      if (element) {
        element.value = this.applicantDataValue[field]
      }
    })

    event.srcElement.classList.add('fr-hidden')
  }
}
