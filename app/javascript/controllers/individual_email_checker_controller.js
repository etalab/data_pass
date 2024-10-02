import { Controller } from '@hotwired/stimulus'

const FORBIDDEN_WORDS_FOR_INDIVIDUAL_EMAILS = [
  'accueil',
  'admin',
  'aidants',
  'asf',
  'bibliotheque',
  'ccas',
  'centre',
  'commune',
  'contact',
  'coordinateur',
  'coordination',
  'datapass',
  'dgs',
  'directeur',
  'direction',
  'directrice',
  'emploi',
  'equipe',
  'espace',
  'evs',
  'famille',
  'info',
  'maire',
  'mairie',
  'mds',
  'mediatheque',
  'mjc',
  'msap',
  'numerique',
  'office',
  'pole',
  'police',
  'secretariat',
  'services',
  'sg',
  'social',
  'urbanisme',
  'vielocale',
  'ville',
  'welcome'
]

export default class extends Controller {
  connect () {
    const controller = this

    this.stopWords = ['mairie', 'contact']
    this.input = this.element
    this.inputGroup = this.element.closest('.fr-input-group')

    this.errorMessage = document.createElement('p')
    this.errorMessage.classList.add('fr-error-text')
    this.errorMessage.style.display = 'none'
    this.input.insertAdjacentElement('afterend', this.errorMessage)

    this.input.addEventListener('input', () => {
      controller.validate()
    })
  }

  validate () {
    const email = this.input.value

    this._clearError()

    if (this._validateEmailFormat(email) && this._containsStopWord(email)) {
      this._displayError("L'email doit être un email nominatif")
    }
  }

  _validateEmailFormat (email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  _containsStopWord (email) {
    return FORBIDDEN_WORDS_FOR_INDIVIDUAL_EMAILS.some((word) => email.toLowerCase().includes(word))
  }

  _displayError (message) {
    this.inputGroup.classList.add('fr-input-group--error')
    this.input.classList.add('fr-input--error')

    this.errorMessage.innerText = message
    this.errorMessage.style.display = 'block'
  }

  _clearError () {
    this.inputGroup.classList.remove('fr-input-group--error')
    this.input.classList.remove('fr-input--error')

    this.errorMessage.innerText = ''
    this.errorMessage.style.display = 'none'
  }
}
