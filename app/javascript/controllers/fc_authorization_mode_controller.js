import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['selectContainer']

  toggle (event) {
    if (event.currentTarget.value === 'use_existing') {
      this.selectContainerTarget.classList.remove('fr-hidden')
      this.selectContainerTarget.setAttribute('aria-hidden', 'false')
    } else {
      this.selectContainerTarget.classList.add('fr-hidden')
      this.selectContainerTarget.setAttribute('aria-hidden', 'true')
      this.clearSelect()
    }
  }

  clearSelect () {
    const select = this.selectContainerTarget.querySelector('select')
    if (select) select.value = ''
  }
}
