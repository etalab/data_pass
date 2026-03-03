import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['name', 'preview']

  update () {
    this.previewTarget.textContent = this.nameToUid(this.nameTarget.value)
  }

  nameToUid (name) {
    return name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '_')
      .replace(/^_+|_+$/g, '')
  }
}
