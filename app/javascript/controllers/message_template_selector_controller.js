import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['textarea', 'previewMessage']
  static values = {
    templates: Array,
    authorizationRequestData: Object
  }

  connect () {
    this.boundUpdatePreview = this.updatePreview.bind(this)
    this.textareaTarget.addEventListener('input', this.boundUpdatePreview)
  }

  disconnect () {
    this.textareaTarget.removeEventListener('input', this.boundUpdatePreview)
  }

  updatePreview () {
    if (!this.hasPreviewMessageTarget) return

    const message = this.textareaTarget.value.trim()
    this.previewMessageTarget.textContent = message || '<MESSAGE PERSONNALISÉ>'
  }

  applyTemplate (event) {
    event.preventDefault()
    const templateId = event.currentTarget.dataset.templateId

    if (!templateId) {
      return
    }

    const template = this.templatesValue.find(t => t.id === parseInt(templateId))

    if (!template) {
      return
    }

    const interpolatedContent = this.interpolate(template.content)
    this.textareaTarget.value = interpolatedContent
    this.textareaTarget.dispatchEvent(new Event('input', { bubbles: true }))
  }

  interpolate (content) {
    let result = content

    Object.keys(this.authorizationRequestDataValue).forEach(key => {
      const placeholder = `%{${key}}`
      const value = this.authorizationRequestDataValue[key]
      result = result.replace(new RegExp(placeholder.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), value)
    })

    return result
  }
}
