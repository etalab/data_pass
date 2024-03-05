import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['source', 'destination']

  connect () {
    this.adjustHeight()
  }

  adjustHeight () {
    this.destinationTargets.forEach((destination) => {
      destination.style.height = 'auto'
      destination.style.height = (this.sourceTarget.scrollHeight) + 'px'
    })
  }
}
