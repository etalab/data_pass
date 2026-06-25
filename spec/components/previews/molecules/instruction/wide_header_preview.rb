class Molecules::Instruction::WideHeaderPreview < ApplicationPreview
  def minimal
    render Molecules::Instruction::WideHeader.new(title: 'Fournisseurs de données')
  end

  def data_providers_index
    render Molecules::Instruction::WideHeader.new(
      title: 'Fournisseurs de données',
      dsfr_logo: 'artwork/pictograms/buildings/city-hall.svg'
    ) do |component|
      component.with_subtitle_content do
        tag.p('Choisissez un fournisseur de données pour gérer ses formulaires', class: 'fr-mb-0')
      end
    end
  end

  # @label Data Provider's Definitions
  def data_provider_definitions
    data_provider = DataProvider.first!
    render Molecules::Instruction::WideHeader.new(
      logo_asset: data_provider.logo,
      title: data_provider.name,
      back_link: { path: '#', text: 'Fournisseurs de données' }
    ) do |component|
      component.with_subtitle_content do
        ActionController::Base.helpers.link_to data_provider.link, data_provider.link,
          target: '_blank', rel: 'noopener external', class: 'fr-link'
      end
    end
  end
end
