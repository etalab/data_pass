class Molecules::Instruction::WideHeaderPreview < ApplicationPreview
  def minimal
    render Molecules::Instruction::WideHeader.new(title: 'Fournisseurs de données')
  end

  def with_right_content
    render Molecules::Instruction::WideHeader.new(title: 'Fournisseurs de données') do |component|
      component.with_right_content do
        tag.button('Ajouter des choses aux trucs', class: 'fr-btn fr-btn--sm fr-icon-add-line fr-btn--icon-left')
      end
    end
  end

  def with_breadcrumbs
    render Molecules::Instruction::WideHeader.new(
      title: 'API Particulier',
      breadcrumbs: [
        { label: 'Formulaires', href: '#' },
        { label: 'API Particulier' }
      ]
    )
  end

  def with_all_options
    authorization_definition = AuthorizationDefinition.find('api_entreprise')

    render Molecules::Instruction::WideHeader.new(
      title: 'API Particulier',
      logo_asset: authorization_definition.provider.logo,
      breadcrumbs: [
        { label: 'Formulaires', href: '#' },
        { label: 'API Particulier' }
      ]
    ) do |component|
      component.with_subtitle_content do
        tag.p('Sous-titre du fournisseur de données', class: 'fr-mb-0')
      end

      component.with_right_content do
        tag.button('Ajouter des choses aux trucs', class: 'fr-btn fr-btn--sm fr-icon-add-line fr-btn--icon-left')
      end
    end
  end
end
