import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['target', 'addButton']
  static values = { inputSelector: String, ariaLabelTemplate: String }

  focusNew () {
    setTimeout(() => {
      this._renumberAriaLabels()
      const inputs = this.targetTarget.querySelectorAll(this.inputSelectorValue)
      inputs[inputs.length - 1]?.focus()
    }, 0)
  }

  focusAfterRemove () {
    setTimeout(() => {
      this._renumberAriaLabels()
      if (this.hasAddButtonTarget) this.addButtonTarget.focus()
    }, 0)
  }

  _renumberAriaLabels () {
    const inputs = this.targetTarget.querySelectorAll(this.inputSelectorValue)
    inputs.forEach((input, index) => {
      input.setAttribute('aria-label', this.ariaLabelTemplateValue.replace('NEW_RECORD', index + 1))
    })
  }
}
