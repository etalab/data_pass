import { Controller } from '@hotwired/stimulus'
import { useDirtyFormTracking, isDirty } from 'stimulus-library'

export default class extends Controller {
  connect () {
    useDirtyFormTracking(this, this.element)
    this.forceDirty = false

    this._setupFileDeletedListener()
    this.update()
  }

  disconnect () {
    this._removeFileDeletedListener()
  }

  _setupFileDeletedListener () {
    this.fileDeletedHandler = this._handleFileDeleted.bind(this)
    this.element.addEventListener('file-deleted', this.fileDeletedHandler)
  }

  _removeFileDeletedListener () {
    this.element.removeEventListener('file-deleted', this.fileDeletedHandler)
  }

  _handleFileDeleted (event) {
    this.markAsDirty()
  }

  submit (event) {
    const isFormDirty = isDirty(this.element) || this.forceDirty
    if (isFormDirty) { return }

    event.preventDefault()
  }

  update () {
    const isFormDirty = isDirty(this.element) || this.forceDirty
    if (isFormDirty) {
      this._toggleSubmitButtons(false)
    } else {
      this._toggleSubmitButtons(true)
    }
  }

  markAsDirty () {
    this.forceDirty = true
    this.update()
  }

  //

  _toggleSubmitButtons (state) {
    this.element.querySelectorAll('button[type="submit"], input[type="submit"]').forEach((button) => {
      button.disabled = state
    })
  }
}
