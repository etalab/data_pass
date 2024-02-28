import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  perform () {
    this.element.submit()
  }
}
