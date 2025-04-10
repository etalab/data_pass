import { Controller } from '@hotwired/stimulus'

// Usage
// <!-- Copy text from an attribute -->
// <div data-controller="clipboard" data-clipboard-content-value="Text to copy">
//   <button data-action="click->clipboard#copy">Copy</button>
// </div>
//
// <!-- Copy text from an input or textarea -->
// <div data-controller="clipboard">
//   <textarea data-clipboard-target="source">Text to copy</textarea>
//   <button data-action="click->clipboard#copy">Copy</button>
// </div>
//
// <!-- Custom success message -->
// <div data-controller="clipboard"
//      data-clipboard-content-value="Text to copy"
//      data-clipboard-success-message-value="Copied to clipboard!"
//      data-clipboard-original-message-value="Copy to clipboard">
//   <button data-action="click->clipboard#copy">Copy to clipboard</button>
// </div>
export default class extends Controller {
  static targets = ['source']
  static values = {
    content: String,
    successMessage: { type: String, default: 'Copié !' },
    originalMessage: { type: String, default: 'Copier' }
  }

  copy (event) {
    event.preventDefault()

    let textToCopy = ''

    // Priority: 1. Explicit content value, 2. Source target's value, 3. Source target's text content
    if (this.hasContentValue && this.contentValue.trim() !== '') {
      textToCopy = this.contentValue
    } else if (this.hasSourceTarget) {
      textToCopy = this.sourceTarget.value || this.sourceTarget.textContent || ''
    } else {
      console.warn('No content to copy was provided')
      return
    }

    // Use the Clipboard API to copy text
    navigator.clipboard.writeText(textToCopy)
      .then(() => {
        this.showSuccess(event.target)
      })
      .catch(error => {
        console.error('Failed to copy text: ', error)
        this.showError(event.target)
      })
  }

  showSuccess (element) {
    const originalText = element.textContent
    element.textContent = this.hasSuccessMessageValue ? this.successMessageValue : 'Copié !'

    setTimeout(() => {
      element.textContent = this.hasOriginalMessageValue ? this.originalMessageValue : originalText
    }, 2000)
  }

  showError (element) {
    const originalText = element.textContent
    element.textContent = 'Echec de la copie !'

    setTimeout(() => {
      element.textContent = this.hasOriginalMessageValue ? this.originalMessageValue : originalText
    }, 2000)
  }
}
