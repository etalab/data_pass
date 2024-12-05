import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modality', 'franceConnectSelector', 'franceConnectContainer', 'nextStage', 'links']

  trigger () {
    const modalityValue = this.modalityTargets.find(modality => modality.checked).value

    if (modalityValue === 'with_france_connect') {
      this.show(this.franceConnectContainerTarget)
      this.showNextStageIfHabilitationSelected()
    } else {
      this.hide(this.franceConnectContainerTarget)
      this.emptyFranceConnectSelector()
      this.showNextStage()
    }

    this.addToLinks({ 'attributes[modalities]': modalityValue })
  }

  showNextStageIfHabilitationSelected () {
    if (this.hasFranceConnectSelectorTarget) {
      this.franceConnectSelectorTarget.required = 'required'
      const franceConnectAuthorizationId = this.valueOrDefaultFranceConnectAuthorizationId()
      this.addToLinks({ 'attributes[france_connect_authorization_id]': franceConnectAuthorizationId })
      this.showNextStage()
    } else {
      this.hideNextStage()
    }
  }

  valueOrDefaultFranceConnectAuthorizationId () {
    if (!this.franceConnectSelectorTarget.value) {
      const defaultValue = Array.from(this.franceConnectSelectorTarget.options).filter(option => option.value)[0].value
      this.franceConnectSelectorTarget.value = defaultValue
    }

    return this.franceConnectSelectorTarget.value
  }

  emptyFranceConnectSelector () {
    if (this.hasFranceConnectSelectorTarget) {
      this.franceConnectSelectorTarget.value = null
      this.franceConnectSelectorTarget.required = ''
      this.removeFromLinks('attributes[france_connect_authorization_id]')
    }
  }

  showNextStage () {
    if (this.hasNextStageTarget) {
      this.show(this.nextStageTarget)
    }
  }

  hideNextStage () {
    if (this.hasNextStageTarget) {
      this.hide(this.nextStageTarget)
    }
  }

  show (element) {
    element.classList.remove('fr-hidden')
  }

  hide (element) {
    element.classList.add('fr-hidden')
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

  removeFromLinks (param) {
    this.linksTargets.forEach((link) => {
      this.removeFromLink(link, param)
    })
  }

  removeFromLink (link, param) {
    const url = new URL(link.href)
    url.searchParams.delete(param)
    link.href = url
  }
}
