import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { url: String }

  connect () {
    this.form = this.element.closest('form')
    this.save = this.save.bind(this)
    this.abort = this.abort.bind(this)

    this.form.addEventListener('change', this.save)
    this.form.addEventListener('submit', this.abort)
  }

  disconnect () {
    this.form.removeEventListener('change', this.save)
    this.form.removeEventListener('submit', this.abort)
    this.abort()
  }

  save (event) {
    if (event.target.type === 'file') return

    this.abort()
    this.controller = new AbortController()

    fetch(this.urlValue, {
      method: 'POST',
      body: this.formData(),
      headers: { Accept: 'text/vnd.turbo-stream.html', 'X-CSRF-Token': this.csrfToken() },
      credentials: 'same-origin',
      signal: this.controller.signal
    })
      .then((response) => this.isTurboStream(response) ? response.text() : '')
      .then((html) => { if (html) window.Turbo.renderStreamMessage(html) })
      .catch(() => {})
  }

  isTurboStream (response) {
    const contentType = response.headers.get('Content-Type') || ''

    return response.ok && !response.redirected && contentType.startsWith('text/vnd.turbo-stream.html')
  }

  abort () {
    if (this.controller) this.controller.abort()
  }

  csrfToken () {
    const meta = document.querySelector('meta[name="csrf-token"]')

    return meta ? meta.content : ''
  }

  formData () {
    const data = new FormData(this.form)

    this.form.querySelectorAll('input[type="file"]').forEach((input) => data.delete(input.name))
    data.delete('authenticity_token')
    data.set('_method', 'patch')

    return data
  }
}
