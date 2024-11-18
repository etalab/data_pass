import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['defaultResult', 'editorResult', 'sandboxResult']

  chooseEditorWithSandbox (event) {
    this.defaultResultTarget.classList.add('fr-hidden')

    if (event.target.value === 'true') {
      this.editorResultTarget.classList.remove('fr-hidden')
      this.sandboxResultTarget.classList.add('fr-hidden')
    } else {
      this.editorResultTarget.classList.add('fr-hidden')
      this.sandboxResultTarget.classList.remove('fr-hidden')
    }
  }
}
