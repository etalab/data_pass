import { Controller } from '@hotwired/stimulus'

const FORMATS = {
  https_url: /^https:\/\/[^\s/.]+(\.[^\s/.]+)+(\/\S*)?$/,
  email: /^[^\s@]+@[^\s@]+\.[a-zA-Z]{2,}$/,
  phone: /^(0[1-9]([\s.-]*\d{2}){4}|\+33[\s.-]*[1-9]([\s.-]*\d{2}){4}|\+(590|594|596)[\s.-]*[1-9]([\s.-]*\d{2}){4}|\+262[\s.-]*\d{2}([\s.-]*\d{2}){3}|\+(508|681|687)[\s.-]*\d{2}([\s.-]*\d{2}){2}|\+689[\s.-]*4\d([\s.-]*\d{2}){2})$/
}

export default class extends Controller {
  static values = { messages: Object }

  connect () {
    this.check = this.check.bind(this)
    this.element.addEventListener('focusout', this.check)
  }

  disconnect () {
    this.element.removeEventListener('focusout', this.check)
  }

  check (event) {
    const input = event.target
    const kind = input.dataset && input.dataset.fieldFormatKind
    if (!kind) return

    const value = this.normalize(kind, input.value)
    const valid = value === '' || FORMATS[kind].test(value)

    this.display(input, valid ? null : this.messagesValue[kind])
  }

  normalize (kind, value) {
    const trimmed = value.trim()
    if (kind !== 'phone') return trimmed

    return trimmed.replace(/(\+\d{1,3})\s*\(\s*0\s*\)/, '$1 ').replace(/[()]/g, '').replace(/\s+/g, ' ').trim()
  }

  display (input, message) {
    const group = input.closest('.fr-input-group')
    const messageId = `${input.id}-format-message`
    const existing = document.getElementById(messageId)

    if (existing) existing.remove()
    group.classList.toggle('fr-input-group--error', Boolean(message))
    input.classList.toggle('fr-input--error', Boolean(message))
    this.describe(input, messageId, Boolean(message))

    if (!message) return

    const paragraph = document.createElement('p')
    paragraph.id = messageId
    paragraph.className = 'fr-message fr-message--error'
    paragraph.textContent = message
    input.insertAdjacentElement('afterend', paragraph)
  }

  describe (input, messageId, add) {
    const ids = (input.getAttribute('aria-describedby') || '').split(' ').filter((id) => id && id !== messageId)
    if (add) ids.push(messageId)

    if (ids.length) {
      input.setAttribute('aria-describedby', ids.join(' '))
    } else {
      input.removeAttribute('aria-describedby')
    }
  }
}
