class AlertComponentPreview < ApplicationPreview
  # @param type select { choices: [success, info, warning, error] }
  # @param close_button toggle
  # @param multiple_messages toggle
  def default(type: :error, close_button: true, multiple_messages: false)
    titles = {
      success: 'Demande sauvegardée avec succès',
      info: 'Information',
      warning: 'Attention',
      error: "Nous n'avons pas pu sauvegarder votre demande"
    }

    single_messages = {
      success: 'Votre demande a bien été enregistrée.',
      info: 'Ceci est une information importante.',
      warning: 'Cette action nécessite votre attention.',
      error: 'Certains champs de votre demande ne sont pas valides, merci de les corriger'
    }

    list_messages = [
      "Le champ email n'est pas valide",
      'Le SIRET est obligatoire',
      'La description doit contenir au moins 10 caractères'
    ]

    render AlertComponent.new(
      type: type.to_sym,
      title: titles[type.to_sym],
      messages: multiple_messages ? list_messages : single_messages[type.to_sym],
      close_button: close_button
    )
  end
end
