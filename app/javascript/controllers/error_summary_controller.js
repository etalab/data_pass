import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.element.scrollIntoView({ block: 'start' })
    this.element.focus({ preventScroll: true })
  }
}
