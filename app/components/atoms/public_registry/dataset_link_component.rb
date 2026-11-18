class Atoms::PublicRegistry::DatasetLinkComponent < ApplicationComponent
  DATASETS_URL = 'https://www.data.gouv.fr/datasets/'.freeze

  def call
    render Atoms::LinkComponent.new(
      text: safe_join([t('.text'), tag.span(t('.new_window'), class: 'fr-sr-only')]),
      path: dataset_url,
      class: 'fr-link--sm',
      target: '_blank'
    )
  end

  private

  def dataset_url
    "#{DATASETS_URL}#{DatagouvAPIClient.dataset_slug}"
  end
end
