import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['submit']
  static values = { message: String }

  connect () {
    this.update()
  }

  update () {
    if (this.hasDeveloperRole()) {
      this.submitTarget.removeAttribute('data-turbo-confirm')
    } else {
      this.submitTarget.setAttribute('data-turbo-confirm', this.messageValue)
    }
  }

  hasDeveloperRole () {
    const selects = this.element.querySelectorAll('select[name="instruction_user_right_form[rights][][role_type]"]')
    return Array.from(selects).some(select => select.value === 'developer')
  }
}
