import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this._createScrollToTopButton()
  }

  _createScrollToTopButton () {
    const button = document.createElement('a')
    button.textContent = 'Haut de page'
    button.href = '#'
    button.classList.add('fr-scroll-to-top')
    button.classList.add('fr-link')
    button.classList.add('fr-link--icon-left')
    button.classList.add('fr-icon-arrow-up-line')

    button.addEventListener('click', (event) => {
      event.preventDefault()
      this._scrollToTop()
    })

    document.body.appendChild(button)

    window.addEventListener('scroll', () => {
      if (window.scrollY > 200) {
        button.classList.add('show')
      } else {
        button.classList.remove('show')
      }
    })
  }

  _scrollToTop () {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
  }
}
