import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.element.classList.add('sticky-btns-group')
    this.setStickiness()

    window.addEventListener('scroll', () => {
      this.setStickiness()
    })
  }

  disconnect () {
    window.removeEventListener('scroll', () => this.setStickiness())
    this.element.classList.remove('sticky-btns-group')
    this.element.classList.remove('is-sticky')
  }

  setStickiness () {
    if (this.belowFooter()) {
      this.element.classList.remove('is-sticky')
    } else {
      this.element.classList.add('is-sticky')
    }
  }

  belowFooter () {
    const footerTop = this.getFooterTop()
    return window.scrollY + window.innerHeight > footerTop
  }

  getFooterTop () {
    const footer = document.querySelector('.fr-footer')
    return footer ? footer.offsetTop : 0
  }
}
