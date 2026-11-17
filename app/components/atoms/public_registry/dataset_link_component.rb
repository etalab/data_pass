class Atoms::PublicRegistry::DatasetLinkComponent < ApplicationComponent
  DATASET_URL = 'https://www.data.gouv.fr/datasets/habilitations-datapass-validees'.freeze

  def call
    render Atoms::LinkComponent.new(
      text: safe_join([t('.text'), tag.span(t('.new_window'), class: 'fr-sr-only')]),
      path: DATASET_URL,
      class: 'fr-link--sm',
      target: '_blank',
      title: t('.title')
    )
  end
end
