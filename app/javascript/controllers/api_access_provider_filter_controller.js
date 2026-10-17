import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['application', 'dataProvider']

  connect () {
    this.filter()
  }

  filter () {
    const applicationId = Number(this.applicationTarget.value)

    this.dataProviderTarget.querySelectorAll('option[data-application-ids]').forEach(option => {
      const covered = !applicationId || JSON.parse(option.dataset.applicationIds).includes(applicationId)

      option.hidden = !covered
      option.disabled = !covered
    })

    if (this.dataProviderTarget.selectedOptions[0]?.disabled) this.dataProviderTarget.value = ''
  }
}
