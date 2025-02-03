import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['withEditorsSection', 'withoutEditorsSection']

  toggleEditor (event) {
    if (event.target.value === 'true') {
      this.show(this.withEditorsSectionTarget)
      this.hide(this.withoutEditorsSectionTarget)
    } else {
      this.hide(this.withEditorsSectionTarget)
      this.show(this.withoutEditorsSectionTarget)
    }
  }

  show (element) {
    element.classList.remove('fr-hidden')
  }

  hide (element) {
    element.classList.add('fr-hidden')
  }
}
