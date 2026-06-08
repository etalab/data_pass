import { Controller } from '@hotwired/stimulus'

const GEO_API_BASE_URL = 'https://geo.api.gouv.fr'

export default class extends Controller {
  static targets = ['summary', 'showAll', 'list']
  static values = {
    type: String,
    code: String,
    communeTemplate: String,
    departementTemplate: String,
    regionTemplate: String,
    unavailable: String
  }

  connect () {
    this.load()
  }

  async load () {
    try {
      const { name, communes } = await this.resolve()
      this.communes = communes
      this.summaryTarget.textContent = this.interpolate(this.templateFor(this.typeValue), {
        name,
        count: communes.length
      })

      if (this.typeValue !== 'commune' && communes.length > 0) {
        this.showAllTarget.classList.remove('fr-hidden')
      }
    } catch {
      this.summaryTarget.textContent = this.unavailableValue
    }
  }

  async resolve () {
    if (this.typeValue === 'commune') {
      const commune = await this.fetchJson(`/communes/${this.codeValue}?fields=nom`)
      return { name: commune.nom, communes: [] }
    }

    if (this.typeValue === 'departement') {
      const [departement, communes] = await Promise.all([
        this.fetchJson(`/departements/${this.codeValue}?fields=nom`),
        this.fetchJson(`/departements/${this.codeValue}/communes?fields=nom`)
      ])
      return { name: departement.nom, communes }
    }

    const [region, departements] = await Promise.all([
      this.fetchJson(`/regions/${this.codeValue}?fields=nom`),
      this.fetchJson(`/regions/${this.codeValue}/departements?fields=code`)
    ])
    const communesByDept = await Promise.all(
      departements.map((departement) => this.fetchJson(`/departements/${departement.code}/communes?fields=nom`))
    )
    return { name: region.nom, communes: communesByDept.flat() }
  }

  async fetchJson (path) {
    const response = await fetch(`${GEO_API_BASE_URL}${path}`, { headers: { Accept: 'application/json' } })
    if (!response.ok) throw new Error('geo unavailable')

    return response.json()
  }

  showCommunes () {
    this.listTarget.innerHTML = ''
    this.communes.forEach((commune) => {
      const item = document.createElement('li')
      item.classList.add('fr-col-12', 'fr-col-md-6')
      item.textContent = commune.nom
      this.listTarget.appendChild(item)
    })

    this.listTarget.classList.remove('fr-hidden')
    this.showAllTarget.classList.add('fr-hidden')
  }

  templateFor (type) {
    if (type === 'commune') return this.communeTemplateValue
    if (type === 'departement') return this.departementTemplateValue
    return this.regionTemplateValue
  }

  interpolate (template, values) {
    return template.replace(/%\{(\w+)\}/g, (_, key) => values[key])
  }
}
