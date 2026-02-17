import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['selectContainer']

  toggle (event) {
    const select = this.selectContainerTarget.querySelector('select')

    if (event.currentTarget.value === 'use_existing') {
      this.selectContainerTarget.classList.remove('fr-hidden')
      this.selectContainerTarget.setAttribute('aria-hidden', 'false')
      if (select) select.required = true
    } else {
      this.selectContainerTarget.classList.add('fr-hidden')
      this.selectContainerTarget.setAttribute('aria-hidden', 'true')
      if (select) {
        select.value = ''
        select.required = false
      }
    }
  }
}
