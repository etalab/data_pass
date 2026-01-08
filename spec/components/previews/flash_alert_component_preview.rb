class FlashAlertComponentPreview < ViewComponent::Preview
  def success
    render FlashAlertComponent.new(
      type: :success,
      data: { 'title' => 'Succès', 'description' => 'Opération réussie' }
    )
  end

  def success_tiny
    render FlashAlertComponent.new(
      type: :success,
      data: { 'title' => 'Sauvegardé', 'tiny' => true }
    )
  end

  def error_with_messages
    render FlashAlertComponent.new(
      type: :error,
      data: {
        'title' => 'Erreur',
        'description' => 'Des erreurs sont survenues',
        'errors' => ['Champ requis', 'Format invalide']
      }
    )
  end

  def warning
    render FlashAlertComponent.new(
      type: :warning,
      data: { 'title' => 'Attention', 'description' => 'Vérifiez les informations' }
    )
  end

  def info
    render FlashAlertComponent.new(
      type: :info,
      data: { 'title' => 'Information', 'description' => 'Note informative' }
    )
  end
end
