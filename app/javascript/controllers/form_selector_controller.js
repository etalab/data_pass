import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['select', 'description', 'link']

  updateForm () {
    const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex]
    const description = selectedOption.dataset.description
    const formUid = selectedOption.value

    if (description) {
      this.descriptionTarget.innerHTML = this.formatText(description)
    }

    const url = new URL(this.linkTarget.href)
    url.searchParams.set('form_uid', formUid)
    this.linkTarget.href = url.toString()
  }

  formatText (text) {
    return text.replace(/\n/g, '<br>')
  }
}
