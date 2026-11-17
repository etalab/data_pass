import { Controller } from '@hotwired/stimulus'

const I18N_APPROXIMATIONS = { æ: 'ae', ð: 'd', '×': 'x', ø: 'o', þ: 'th', ß: 'ss', đ: 'd', ħ: 'h', ı: 'i', ĳ: 'ij', ĸ: 'k', ŀ: 'l', ł: 'l', ŉ: "'n", ŋ: 'ng', œ: 'oe', ŧ: 't' }
const I18N_APPROXIMATED = new RegExp(`[${Object.keys(I18N_APPROXIMATIONS).join('')}]`, 'g')

export function proposeIdentifier (name) {
  return name
    .toLowerCase()
    .replace(I18N_APPROXIMATED, (character) => I18N_APPROXIMATIONS[character])
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

export default class extends Controller {
  static targets = ['name', 'identifier', 'counter', 'previewName', 'previewInitial']
  static values = { maxLength: Number, counter: String, placeholder: String }

  connect () {
    const identifier = this.identifierTarget.value.trim()
    this.identifierProposed = identifier === '' || identifier === proposeIdentifier(this.nameTarget.value)
  }

  nameChanged () {
    const name = this.nameTarget.value

    this.updateCounter(name)
    this.updatePreview(name)
    if (this.identifierProposed) this.identifierTarget.value = proposeIdentifier(name)
  }

  identifierChanged () {
    this.identifierProposed = this.identifierTarget.value.trim() === ''
    if (this.identifierProposed) this.identifierTarget.value = proposeIdentifier(this.nameTarget.value)
  }

  updateCounter (name) {
    this.counterTarget.textContent = this.counterValue.replace('__count__', name.length)
    this.counterTarget.classList.toggle('is-over', name.length > this.maxLengthValue)
  }

  updatePreview (name) {
    const trimmed = name.trim()

    this.previewNameTarget.textContent = trimmed || this.placeholderValue
    this.previewInitialTarget.textContent = (trimmed[0] || '?').toUpperCase()
  }
}
