import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    target: String
  }

  go (event) {
    const target = document.getElementById(this.targetValue)

    if (target) {
      window.scroll({
        top: target.offsetTop,
        behavior: 'smooth'
      })
    }
  }
}
