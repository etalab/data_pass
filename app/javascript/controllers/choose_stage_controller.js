import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['editorResult', 'sandboxResult']

  chooseEditorWithSandbox (event) {
    if (event.target.value === 'true') {
      this.editorResultTarget.classList.remove('fr-hidden')
      this.sandboxResultTarget.classList.add('fr-hidden')
    } else {
      this.editorResultTarget.classList.add('fr-hidden')
      this.sandboxResultTarget.classList.remove('fr-hidden')
    }
  }
}
