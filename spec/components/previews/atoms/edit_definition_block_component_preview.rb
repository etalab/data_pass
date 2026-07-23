class Atoms::EditDefinitionBlockComponentPreview < ApplicationPreview
  def default
    render Atoms::EditDefinitionBlockComponent.new(title: 'Décrivez votre projet') do
      tag.p 'Contenu de la section avec les champs du formulaire.'
    end
  end

  def static_block
    render Atoms::EditDefinitionBlockComponent.new(title: 'Décrivez votre projet', static_block: true) do
      tag.p 'Contenu de la section avec les champs du formulaire.'
    end
  end
end
