import { Application } from '@hotwired/stimulus'
import { AutoSubmitFormController, NestedFormController, ToggleClassController } from 'stimulus-library'

const application = Application.start()
application.register('auto-submit-form', AutoSubmitFormController)
application.register('nested-form', NestedFormController)
application.register('toggle-class', ToggleClassController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

export { application }
