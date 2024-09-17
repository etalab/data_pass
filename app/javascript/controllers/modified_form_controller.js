import { Controller } from '@hotwired/stimulus'
import { useDirtyFormTracking, isDirty } from 'stimulus-library'

export default class extends Controller {
  connect () {
    useDirtyFormTracking(this, this.element)

    this.update()
  }

  submit (event) {
    if (isDirty(this.element)) { return }

    event.preventDefault()
  }

  update () {
    if (isDirty(this.element)) {
      this._toggleSubmitButtons(false)
    } else {
      this._toggleSubmitButtons(true)
    }
  }

  //

  _toggleSubmitButtons (state) {
    this.element.querySelectorAll('button[type="submit"], input[type="submit"]').forEach((button) => {
      button.disabled = state
    })
  }
}
