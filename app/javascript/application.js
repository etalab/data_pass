// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'
import 'controllers'

document.addEventListener('turbo:click', (event) => {
  const target = new URL(event.detail.url)
  const samePage = target.pathname === window.location.pathname && target.search === window.location.search
  if (samePage && target.hash) event.preventDefault()
})

document.addEventListener('turbo:frame-missing', (event) => {
  const { detail: { response, visit } } = event
  event.preventDefault()
  visit(response)
})
