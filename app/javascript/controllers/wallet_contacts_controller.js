import { Controller } from '@hotwired/stimulus'

const IDENTITY_FIELDS = ['given_name', 'family_name', 'email']

export default class extends Controller {
  static values = { applicant: Object }

  static targets = ['block', 'itsMe', 'notification']

  connect () {
    this.refresh()
  }

  fill (event) {
    const block = event.currentTarget.closest('[data-wallet-contacts-target="block"]')

    IDENTITY_FIELDS.forEach((field) => {
      const input = this.field(block, field)
      input.value = this.applicantValue[field] || ''
      if (input.value.trim() !== '') this.clearServerError(input)
      input.dispatchEvent(new Event('input', { bubbles: true }))
      input.dispatchEvent(new Event('change', { bubbles: true }))
      input.dispatchEvent(new window.FocusEvent('focusout', { bubbles: true }))
    })

    this.refresh()
    this.announce()
    this.field(block, 'phone_number').focus()
  }

  refresh () {
    const applicantBlock = this.blockTargets.find((block) => this.isApplicant(block))

    this.blockTargets.forEach((block) => {
      const button = block.querySelector('[data-wallet-contacts-target="itsMe"]')
      button.hidden = Boolean(applicantBlock) && applicantBlock !== block
    })
  }

  isApplicant (block) {
    return IDENTITY_FIELDS.every((field) => {
      const value = this.comparable(this.field(block, field).value)

      return value !== '' && value === this.comparable(this.applicantValue[field])
    })
  }

  field (block, name) {
    return block.querySelector(`[data-wallet-contacts-field="${name}"]`)
  }

  clearServerError (input) {
    const messagesId = `${input.id}-messages`
    const messages = document.getElementById(messagesId)
    const describedBy = (input.getAttribute('aria-describedby') || '').split(' ').filter((id) => id && id !== messagesId)

    if (messages) messages.remove()
    input.closest('.fr-input-group').classList.remove('fr-input-group--error')
    input.classList.remove('fr-input--error')
    input.removeAttribute('aria-invalid')

    if (describedBy.length) {
      input.setAttribute('aria-describedby', describedBy.join(' '))
    } else {
      input.removeAttribute('aria-describedby')
    }
  }

  comparable (value) {
    return (value || '').trim().toLowerCase()
  }

  announce () {
    this.notificationTarget.textContent = ''
    window.requestAnimationFrame(() => {
      this.notificationTarget.textContent = this.notificationTarget.dataset.message
    })
  }
}
