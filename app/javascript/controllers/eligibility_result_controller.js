import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['slot', 'aside', 'placeholder', 'store']
  static values = {
    desktopQuery: { type: String, default: '(min-width: 62em)' }
  }

  connect () {
    this.desktopMedia = window.matchMedia(this.desktopQueryValue)
    this.restore = this.restore.bind(this)
    this.desktopMedia.addEventListener('change', this.restore)
    window.addEventListener('pageshow', this.restore)
    this.restore()
  }

  disconnect () {
    this.desktopMedia.removeEventListener('change', this.restore)
    window.removeEventListener('pageshow', this.restore)
  }

  select (event) {
    this.display(event.params.outcome, { announce: true })
  }

  restore () {
    const checkedRadio = this.element.querySelector('input[type="radio"]:checked')

    if (checkedRadio) {
      this.display(checkedRadio.dataset.eligibilityResultOutcomeParam, { announce: false })
    } else {
      this.storeOutcomesExcept(null)
      this.placeholderTarget.hidden = false
    }
  }

  display (outcomeId, { announce }) {
    const outcome = document.getElementById(outcomeId)
    const region = this.regionFor(outcomeId)

    if (!outcome || !region || outcome.parentElement === region) return

    this.storeOutcomesExcept(outcome)
    this.placeholderTarget.hidden = true

    if (announce) {
      region.append(outcome)
    } else {
      this.appendSilently(region, outcome)
    }
  }

  regionFor (outcomeId) {
    if (this.asideTarget.offsetParent !== null) return this.asideTarget

    return this.slotTargets.find(slot => slot.dataset.outcomeId === outcomeId)
  }

  storeOutcomesExcept (keptOutcome) {
    this.regions().forEach(region => {
      Array.from(region.children)
        .filter(outcome => outcome !== keptOutcome)
        .forEach(outcome => this.storeTarget.append(outcome))
    })
  }

  regions () {
    return [this.asideTarget, ...this.slotTargets]
  }

  appendSilently (region, outcome) {
    region.setAttribute('aria-live', 'off')
    region.append(outcome)

    window.requestAnimationFrame(() => {
      window.requestAnimationFrame(() => region.setAttribute('aria-live', 'polite'))
    })
  }
}
