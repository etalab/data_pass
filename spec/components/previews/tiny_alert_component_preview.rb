class TinyAlertComponentPreview < ApplicationPreview
  # @param type select { choices: [success, info, warning, error] }
  # @param dismissible toggle
  def default(type: :success, dismissible: true)
    messages = {
      success: 'Demande sauvegardée',
      info: 'Information importante',
      warning: 'Attention à cette information',
      error: 'Une erreur est survenue'
    }

    render TinyAlertComponent.new(
      type: type.to_sym,
      message: messages[type.to_sym],
      dismissible: dismissible
    )
  end
end
