class AlertComponentPreview < ApplicationPreview
  # @param type select { choices: [success, info, warning, error] }
  # @param close_button toggle
  # @param with_errors toggle
  def default(type: :error, close_button: true, with_errors: false)
    titles = {
      success: 'Demande sauvegardée avec succès',
      info: 'Information',
      warning: 'Attention',
      error: "Nous n'avons pas pu sauvegarder votre demande"
    }

    descriptions = {
      success: 'Votre demande a bien été enregistrée.',
      info: 'Ceci est une information importante.',
      warning: 'Cette action nécessite votre attention.',
      error: 'Certains champs de votre demande ne sont pas valides, merci de les corriger.'
    }

    error_messages = [
      "Le champ email n'est pas valide",
      'Le SIRET est obligatoire',
      'La description doit contenir au moins 10 caractères'
    ]

    render AlertComponent.new(
      type: type.to_sym,
      title: titles[type.to_sym],
      description: descriptions[type.to_sym],
      messages: with_errors ? error_messages : [],
      close_button: close_button
    )
  end
end
