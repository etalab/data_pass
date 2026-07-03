class Atoms::FormButtonsComponentPreview < ApplicationPreview
  def with_initiate_request
    render Atoms::FormButtonsComponent.new(
      copy_request_url: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau',
      initiate_request_path: '/instruction/drafts/api_entreprise/nouveau'
    )
  end

  def without_initiate_request
    render Atoms::FormButtonsComponent.new(
      copy_request_url: 'https://datapass.api.gouv.fr/demandes/api_entreprise/nouveau'
    )
  end
end
