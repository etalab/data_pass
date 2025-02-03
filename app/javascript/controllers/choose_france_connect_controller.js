import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['franceConnectSelector', 'links']

  connect () {
    this.updateFranceConnectId()
  }

  updateFranceConnectId () {
    const franceConnectAuthorizationId = this.valueOrDefaultFranceConnectAuthorizationId()
    this.addToLinks({ 'attributes[france_connect_authorization_id]': franceConnectAuthorizationId })
  }

  valueOrDefaultFranceConnectAuthorizationId () {
    if (!this.franceConnectSelectorTarget.value) {
      const defaultValue = Array.from(this.franceConnectSelectorTarget.options).filter(option => option.value)[0].value
      this.franceConnectSelectorTarget.value = defaultValue
    }
    return this.franceConnectSelectorTarget.value
  }

  addToLinks (params) {
    this.linksTargets.forEach((link) => {
      this.addToLink(link, params)
    })
  }

  addToLink (link, params) {
    const url = new URL(link.href)
    Object.entries(params).forEach(entry => {
      url.searchParams.set(...entry)
    })
    link.href = url
  }
}
