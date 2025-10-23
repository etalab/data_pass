import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['container', 'content']
  static values = {
    defaultClasses: { type: String, default: 'fr-col-12 fr-col-md-8 fr-col-lg-6' }
  }

  static COLUMN_CLASS_PREFIX = 'fr-col'
  static SIZE_MAP = {
    small: 'fr-col-12 fr-col-md-6 fr-col-lg-4',
    medium: 'fr-col-12 fr-col-md-8 fr-col-lg-6',
    large: 'fr-col-12 fr-col-md-10 fr-col-lg-8',
    full: 'fr-col-12'
  }

  connect () {
    this.boundApplySizeClasses = this.applySizeClasses.bind(this)
    this.contentTarget.addEventListener('turbo:frame-load', this.boundApplySizeClasses)
    this.applySizeClasses()
  }

  disconnect () {
    this.contentTarget.removeEventListener('turbo:frame-load', this.boundApplySizeClasses)
  }

  applySizeClasses () {
    const sizeClasses = this.getSizeClasses()
    this.updateContainerClasses(sizeClasses)
  }

  getSizeClasses () {
    const firstChild = this.contentTarget.firstElementChild

    if (!firstChild) {
      return this.defaultClassesValue
    }

    return this.extractSizeClasses(firstChild.dataset) ||
           this.extractSizeClasses(this.contentTarget.dataset) ||
           this.defaultClassesValue
  }

  extractSizeClasses (dataset) {
    if (dataset.modalSizeClasses) {
      return dataset.modalSizeClasses
    }

    if (dataset.modalSize) {
      return this.getPredefinedSizeClasses(dataset.modalSize)
    }

    return null
  }

  getPredefinedSizeClasses (size) {
    return this.constructor.SIZE_MAP[size] || this.defaultClassesValue
  }

  updateContainerClasses (newClasses) {
    const currentClasses = this.containerTarget.className
      .split(' ')
      .filter(cls => cls && !cls.startsWith(this.constructor.COLUMN_CLASS_PREFIX))

    const newClassesArray = newClasses.split(' ').filter(cls => cls)
    const updatedClasses = [...currentClasses, ...newClassesArray]

    this.containerTarget.className = updatedClasses.join(' ')
  }
}
