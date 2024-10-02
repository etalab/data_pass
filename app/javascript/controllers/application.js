import { Application } from '@hotwired/stimulus'
import { AutoSubmitFormController } from 'stimulus-library'

const application = Application.start()
application.register('auto-submit-form', AutoSubmitFormController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }
