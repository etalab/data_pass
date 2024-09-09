import { Controller } from '@hotwired/stimulus'
import {useDirtyFormTracking, isDirty} from 'stimulus-library'

export default class extends Controller {
  static targets = ['submit']
  static values = {preventSubmit: Boolean }

  connect () {
    if (this.preventSubmitValue && this.hasSubmitTarget) { 
      this.submitTarget.disabled = true
    }
    useDirtyFormTracking(this, this.element)
  }

  submit (event) {
    if (!this.preventSubmitValue) { return }
    if (isDirty(this.element)) { return }

    event.preventDefault()
  }

  update () {
    if (!this.hasSubmitTarget) { return }

    if (isDirty(this.element)) {
      this.submitTarget.disabled = false
    } else {
      this.submitTarget.disabled = true
    }
  }
}
