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
end
