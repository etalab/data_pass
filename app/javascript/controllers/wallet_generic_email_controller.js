import { Controller } from '@hotwired/stimulus'

const GENERIC_WORDS = ['contact', 'support', 'aide', 'assistance', 'accueil', 'info', 'service']
const FIRST_NAME_DOT_LAST_NAME = /^([\p{L}-]+)\.([\p{L}-]+)$/u

export default class extends Controller {
  static values = { warning: String }

  connect () {
    this.check = this.check.bind(this)
    this.element.addEventListener('blur', this.check)
  }

  disconnect () {
    this.element.removeEventListener('blur', this.check)
  }

  check () {
    const messageId = `${this.element.id}-generic-warning`
    const existing = document.getElementById(messageId)
    if (existing) existing.remove()
    this.describe(messageId, false)

    if (!this.looksPersonal(this.element.value.trim())) return

    const paragraph = document.createElement('p')
    paragraph.id = messageId
    paragraph.className = 'fr-message fr-message--info fr-mt-1w fr-mb-0'
    paragraph.setAttribute('aria-live', 'polite')
    this.element.closest('.fr-input-group').appendChild(paragraph)
    this.describe(messageId, true)
    window.requestAnimationFrame(() => { paragraph.textContent = this.warningValue })
  }

  describe (messageId, add) {
    const ids = (this.element.getAttribute('aria-describedby') || '').split(' ').filter((id) => id && id !== messageId)
    if (add) ids.push(messageId)

    if (ids.length) {
      this.element.setAttribute('aria-describedby', ids.join(' '))
    } else {
      this.element.removeAttribute('aria-describedby')
    }
  }

  looksPersonal (email) {
    const localPart = email.split('@')[0].toLowerCase()
    const match = localPart.match(FIRST_NAME_DOT_LAST_NAME)
    if (!email.includes('@') || !match) return false

    return !GENERIC_WORDS.includes(match[1]) && !GENERIC_WORDS.includes(match[2])
  }
}
