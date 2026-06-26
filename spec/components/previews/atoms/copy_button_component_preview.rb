class Atoms::CopyButtonComponentPreview < ApplicationPreview
  def default
    render Atoms::CopyButtonComponent.new(
      text_to_copy: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau',
      label: 'Copier le lien de demande'
    )
  end

  def with_extra_classes
    render Atoms::CopyButtonComponent.new(
      text_to_copy: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau',
      label: 'Copier le lien de demande',
      extra_classes: 'authorization-definition-action-btn'
    )
  end
end
