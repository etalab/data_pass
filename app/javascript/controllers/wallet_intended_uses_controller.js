import { Controller } from '@hotwired/stimulus'

const COLLAPSED_ICON = 'fr-icon-arrow-down-s-line'
const EXPANDED_ICON = 'fr-icon-arrow-up-s-line'

export function plural (wordings, count) {
  const form = count === 0 ? 'zero' : (count === 1 ? 'one' : 'other')

  return wordings[form].replace('__count__', count)
}

export default class extends Controller {
  static targets = ['card', 'cardToggle', 'title', 'totals', 'cardSummary', 'purposeCounter', 'attestation', 'claimsCount', 'group', 'groupCount', 'groupToggle', 'sectionToggle', 'preview', 'previewSelect', 'previewData', 'previewPurpose', 'claimError']
  static values = { wordings: Object }

  connect () {
    this.cardTargets.forEach((card) => this.setCardOpen(card, card.dataset.open === 'true'))
    this.attestationTargets.forEach((attestation) => this.initializeGroups(attestation))
    this.sectionToggleTargets.forEach((button) => this.setExpanded(button, false))
    this.showPreview(this.hasPreviewSelectTarget ? this.previewSelectTarget.value : this.previewTargets[0]?.dataset.useId)
  }

  toggleCard (event) {
    const card = event.currentTarget.closest('[data-wallet-intended-uses-target~="card"]')

    this.setCardOpen(card, event.currentTarget.getAttribute('aria-expanded') !== 'true')
  }

  toggleGroup (event) {
    const button = event.currentTarget
    const expanded = button.getAttribute('aria-expanded') !== 'true'

    this.setExpanded(button, expanded)
    button.firstChild.textContent = expanded ? this.wordingsValue.hideClaims : this.wordingsValue.showClaims
  }

  toggleSection (event) {
    this.setExpanded(event.currentTarget, event.currentTarget.getAttribute('aria-expanded') !== 'true')
  }

  nameChanged (event) {
    const card = this.cardOf(event.target)
    const name = event.target.value.trim()
    const title = card.querySelector('[data-wallet-intended-uses-target~="title"]')

    if (name) title.textContent = name
    this.previewOptionsOf(card).forEach((option) => { if (name) option.textContent = name })
  }

  purposeChanged (event) {
    const input = event.target
    const length = input.value.trim().length
    const counter = this.cardOf(input).querySelector('[data-wallet-intended-uses-target~="purposeCounter"]')

    counter.textContent = this.wordingsValue.purposeCounter.replace('__count__', length)
    counter.classList.toggle('is-over', length > Number(input.dataset.maxLength))
    this.previewOf(this.cardOf(input))?.querySelector('[data-wallet-intended-uses-target~="previewPurpose"]')?.replaceChildren(input.value.trim() || this.emphasis(this.wordingsValue.noPurpose))
  }

  claimChanged (event) {
    const card = this.cardOf(event.target)
    const attestation = event.target.closest('[data-wallet-intended-uses-target~="attestation"]')
    const group = event.target.closest('[data-wallet-intended-uses-target~="group"]')

    attestation.querySelector('[data-wallet-intended-uses-target~="claimsCount"]').textContent = plural(this.wordingsValue.claimsCount, this.checkedIn(attestation).length)
    group.querySelector('[data-wallet-intended-uses-target~="groupCount"]').textContent = plural(this.wordingsValue.groupCount, this.checkedIn(group).length)
    this.refreshTotals(card)
    this.refreshPreviewData(card)
    if (this.checkedIn(attestation).length > 0) this.clearClaimError(attestation)
  }

  disconnect () {
    window.cancelAnimationFrame(this.scrollFrame)
  }

  previewChanged () {
    this.showPreview(this.previewSelectTarget.value)
  }

  followFocus (event) {
    this.follow(this.cardOf(event.target))
  }

  followScroll () {
    if (!this.hasPreviewSelectTarget || this.scrollFrame) return

    this.scrollFrame = window.requestAnimationFrame(() => {
      this.scrollFrame = null
      this.follow(this.cardAtReadingLine())
    })
  }

  follow (card) {
    if (!this.hasPreviewSelectTarget || !card || card.dataset.useId === this.previewSelectTarget.value) return

    this.previewSelectTarget.value = card.dataset.useId
    this.showPreview(card.dataset.useId)
  }

  cardAtReadingLine () {
    const readingLine = window.innerHeight / 3
    const reached = this.cardTargets.filter((card) => card.getBoundingClientRect().top <= readingLine)

    return reached[reached.length - 1] || this.cardTargets[0]
  }

  setCardOpen (card, open) {
    const button = card.querySelector('[data-wallet-intended-uses-target~="cardToggle"]')
    const summary = card.querySelector('[data-wallet-intended-uses-target~="cardSummary"]')

    this.setExpanded(button, open)
    button.firstChild.textContent = open ? this.wordingsValue.collapse : this.wordingsValue.edit
    if (!open) this.refreshCardSummary(card)
    summary.hidden = open
  }

  initializeGroups (attestation) {
    attestation.querySelectorAll('[data-wallet-intended-uses-target~="groupToggle"]').forEach((button) => {
      this.setExpanded(button, false)
      button.firstChild.textContent = this.wordingsValue.showClaims
    })
  }

  setExpanded (button, expanded) {
    const controlled = document.getElementById(button.getAttribute('aria-controls'))

    button.setAttribute('aria-expanded', String(expanded))
    button.classList.toggle(EXPANDED_ICON, expanded)
    button.classList.toggle(COLLAPSED_ICON, !expanded)
    if (controlled) controlled.hidden = !expanded
  }

  clearClaimError (attestation) {
    const button = attestation.querySelector('.fr-accordion__btn')
    const message = attestation.querySelector('[data-wallet-intended-uses-target~="claimError"]')
    if (!message) return

    message.remove()
    button.removeAttribute('aria-describedby')
    this.removeSummaryLink(button.id)
  }

  removeSummaryLink (fieldId) {
    const summary = document.getElementById('form-error-summary')
    const link = summary && Array.from(summary.querySelectorAll('a')).find((anchor) => anchor.getAttribute('href') === `#${fieldId}`)
    if (!link) return

    link.closest('li').remove()
    const remaining = summary.querySelectorAll('li').length
    if (remaining === 0) return summary.remove()

    summary.querySelector('.fr-alert__title').textContent = plural(this.wordingsValue.errorSummaryTitle, remaining)
  }

  refreshTotals (card) {
    const attestations = card.querySelectorAll('[data-wallet-intended-uses-target~="attestation"]')
    const text = attestations.length === 0
      ? this.wordingsValue.noAttestation
      : `${plural(this.wordingsValue.attestationsTotal, attestations.length)}, ${plural(this.wordingsValue.claimsTotal, this.checkedIn(card).length)}`

    card.querySelectorAll('[data-wallet-intended-uses-target~="totals"]').forEach((element) => { element.textContent = text })
  }

  refreshCardSummary (card) {
    const summary = card.querySelector('[data-wallet-intended-uses-target~="cardSummary"]')

    summary.replaceChildren(...this.selection(card).map(({ name, labels }) => {
      const item = document.createElement('li')
      const strong = document.createElement('strong')
      strong.textContent = name
      item.append(strong, ` : ${labels.map((label) => label.toLowerCase()).join(', ')}`)
      return item
    }))
  }

  refreshPreviewData (card) {
    const container = this.previewOf(card)?.querySelector('[data-wallet-intended-uses-target~="previewData"]')
    if (!container) return

    const selection = this.selection(card)
    if (selection.length === 0) return container.replaceChildren(this.paragraph(this.wordingsValue.noData, 'fr-text--sm fr-mb-0 wx-muted'))

    container.replaceChildren(...selection.flatMap(({ name, labels }) => [this.paragraph(name, 'fr-text--sm fr-text--bold fr-mb-0'), this.list(labels)]))
  }

  selection (card) {
    return Array.from(card.querySelectorAll('[data-wallet-intended-uses-target~="attestation"]'))
      .map((attestation) => ({ name: attestation.dataset.attestationName, labels: this.checkedIn(attestation).map((input) => input.dataset.claimLabel) }))
      .filter(({ labels }) => labels.length > 0)
  }

  showPreview (useId) {
    this.previewTargets.forEach((preview) => { preview.hidden = preview.dataset.useId !== useId })
  }

  checkedIn (element) {
    return Array.from(element.querySelectorAll('input[type="checkbox"]:checked'))
  }

  cardOf (element) {
    return element.closest('[data-wallet-intended-uses-target~="card"]')
  }

  previewOf (card) {
    return this.previewTargets.find((preview) => preview.dataset.useId === card.dataset.useId)
  }

  previewOptionsOf (card) {
    return this.hasPreviewSelectTarget ? Array.from(this.previewSelectTarget.options).filter((option) => option.value === card.dataset.useId) : []
  }

  paragraph (text, className) {
    const paragraph = document.createElement('p')
    paragraph.className = className
    paragraph.textContent = text
    return paragraph
  }

  list (labels) {
    const list = document.createElement('ul')
    list.className = 'fr-text--sm fr-mb-0'
    list.replaceChildren(...labels.map((label) => Object.assign(document.createElement('li'), { textContent: label })))
    return list
  }

  emphasis (text) {
    return Object.assign(document.createElement('em'), { textContent: text })
  }
}
