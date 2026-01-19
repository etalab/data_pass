import { Controller } from '@hotwired/stimulus'
export default class extends Controller {
  removeFile (event) {
    const button = event.currentTarget
    const fieldId = button.dataset.fieldId

    const hiddenField = document.getElementById(fieldId)

    if (hiddenField) {
      hiddenField.value = ''
      hiddenField.dispatchEvent(new Event('input', { bubbles: true }))

      const fileDisplay = button.closest('.file-with-remove-button')
      if (fileDisplay) {
        fileDisplay.remove()
      }
    }
  }
}
