import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['editors', 'editor', 'forms', 'form', 'noTeamDisclaimer', 'noEditorDisclaimer', 'editorAlreadyIntegrated']
  static values = {
    editors: Array,
    targetUseCase: String
  }

  chooseTeam (event) {
    this._hideForms()

    switch (event.target.value) {
      case 'internal':
        this._hideEditors()
        this._hideEditorForms()
        if (this.hasTargetUseCaseValue) {
          this._hideOtherUseCaseForms()
        }
        this._showFormsBlock()
        break
      case 'editor':
        this._showEditors()
        break
      case 'none':
        this._hideEditors()
        this._showNoTeamDisclaimer()
        break
    }
  }

  chooseEditor (event) {
    const editor = event.target.value

    if (editor === 'editor_already_integrated') {
      this._showEditorAlreadyIntegrated()
      return
    }

    this.formTargets.forEach((form) => {
      const formTags = this._getFormTags(form)

      if (formTags.includes(editor)) {
        form.classList.remove('fr-hidden')
      } else {
        form.classList.add('fr-hidden')
      }
    })

    if (this.hasTargetUseCaseValue) {
      this._hideOtherUseCaseForms()
    }

    if (this._noForm()) {
      this._showNoEditorDisclaimer()
    } else {
      this._showFormsBlock()
    }
  }

  _getFormTags (form) {
    return JSON.parse(form.getAttribute('data-choose-authorization-request-form-tags'))
  }

  _showEditors () {
    this.editorsTarget.classList.remove('fr-hidden')
  }

  _hideEditors () {
    this.editorsTarget.classList.add('fr-hidden')
    this.editorTargets.forEach((editor) => {
      editor.checked = false
    })
  }

  _hideEditorForms () {
    this._showAllForms()

    this.editorsValue.forEach((editor) => {
      this.formTargets.forEach((form) => {
        const formTags = this._getFormTags(form)

        if (formTags.includes(editor)) {
          form.classList.add('fr-hidden')
        }
      })
    })
  }

  _showFormsBlock () {
    this.formsTarget.classList.remove('fr-hidden')
  }

  _showAllForms () {
    this.formTargets.forEach((form) => {
      form.classList.remove('fr-hidden')
    })
  }

  _hideForms () {
    this.formTargets.forEach((form) => {
      form.classList.add('fr-hidden')
    })
    this.formsTarget.classList.add('fr-hidden')
    this.noTeamDisclaimerTarget.classList.add('fr-hidden')
    if (this.hasEditorAlreadyIntegratedTarget) {
      this.editorAlreadyIntegratedTarget.classList.add('fr-hidden')
    }
    this.noEditorDisclaimerTarget.classList.add('fr-hidden')
  }

  _showNoTeamDisclaimer () {
    this.noTeamDisclaimerTarget.classList.remove('fr-hidden')
  }

  _showNoEditorDisclaimer () {
    this.noEditorDisclaimerTarget.classList.remove('fr-hidden')
    if (this.hasEditorAlreadyIntegratedTarget) {
      this.editorAlreadyIntegratedTarget.classList.add('fr-hidden')
    }
    this.formsTarget.classList.add('fr-hidden')
  }

  _showEditorAlreadyIntegrated () {
    if (this.hasEditorAlreadyIntegratedTarget) {
      this.editorAlreadyIntegratedTarget.classList.remove('fr-hidden')
    }
    this.noEditorDisclaimerTarget.classList.add('fr-hidden')
    this.formsTarget.classList.add('fr-hidden')
  }

  _hideEditorAlreadyIntegrated () {
    if (this.hasEditorAlreadyIntegratedTarget) {
      this.editorAlreadyIntegratedTarget.classList.add('fr-hidden')
    }
  }

  _noForm () {
    return this.formTargets.every((form) => {
      return form.classList.contains('fr-hidden')
    })
  }

  _hideOtherUseCaseForms () {
    this.formTargets.forEach((form) => {
      const formTags = this._getFormTags(form)

      if (!formTags.includes(this.targetUseCaseValue) && !formTags.includes('default')) {
        form.classList.add('fr-hidden')
      }
    })
  }
}
