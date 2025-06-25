import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  visit (event) {
    const selection = window.getSelection()
    if (selection.type !== 'Range') {
      const row = event.currentTarget
      const path = row.attributes['data-href'].value
      window.location.assign(path)
    }
  }
}
