import { Controller } from '@hotwired/stimulus'
import { useDirtyFormTracking, isDirty } from 'stimulus-library'

export default class extends Controller {
  static targets = ['submit']

  connect () {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
    }
    useDirtyFormTracking(this, this.element)

    this.update()
  }

  submit (event) {
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
