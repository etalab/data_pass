import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['franceConnectSelector', 'franceConnectSelectorContainer', 'nextStage', 'links']

  trigger (event) {
    const selectedOption = event.target.value

    if (selectedOption === 'with_france_connect') {
      this.show(this.franceConnectSelectorContainerTarget)

      if (!this.hasFranceConnectSelectorTarget || !this.franceConnectSelectorTarget.value) {
        this.hide(this.nextStageTarget)
      }
    } else {
      this.hide(this.franceConnectSelectorContainerTarget)
      if (this.hasFranceConnectSelectorTarget) {
        this.franceConnectSelectorTarget.value = ''
      }
      this.showNextStage()
    }

    this.updateLinks({ modalite: selectedOption })
  }

  showNextStageIfHabilitationSelected (event) {
    const franceConnectAuthorizationId = event.target.value

    if (franceConnectAuthorizationId) {
      this.updateLinks({ france_connect_authorization_id: franceConnectAuthorizationId })
      this.showNextStage()
    }
  }

  showNextStage () {
    this.show(this.nextStageTarget)
  }

  show (element) {
    element.classList.remove('fr-hidden')
  }

  hide (element) {
    element.classList.add('fr-hidden')
  }

  updateLinks (params) {
    this.linksTargets.forEach((link) => {
      this.updateLink(link, params)
    })
  }

  updateLink (link, params) {
    const url = new URL(link.href)

    Object.entries(params).forEach(entry => {
      url.searchParams.set(...entry)
    })

    link.href = url
  }
}
