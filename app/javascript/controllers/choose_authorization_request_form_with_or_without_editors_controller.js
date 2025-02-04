import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['withEditorsSection', 'withoutEditorsSection']
  static classes = ['hidden']
  
  toggleEditor (event) {
    const shouldShowEditors = event.currentTarget.value === 'true'
    this.toggleEditorState(shouldShowEditors)
  }

  toggleEditorState(shouldShowEditors) {
    if (shouldShowEditors) {
      this.show(this.withEditorsSectionTarget)
      this.hide(this.withoutEditorsSectionTarget)
    } else {
      this.hide(this.withEditorsSectionTarget)
      this.show(this.withoutEditorsSectionTarget)
    }
  }

  show (element) {
    element.classList.remove(this.hiddenClass)
  }

  hide (element) {
    element.classList.add(this.hiddenClass)
  }
}
