class Atoms::EditDefinitionBlockComponentPreview < ApplicationPreview
  def default
    render Atoms::EditDefinitionBlockComponent.new(title: 'Décrivez votre projet', can_edit: true) do
      tag.p 'Contenu de la section avec les champs du formulaire.'
    end
  end

  def readonly
    render Atoms::EditDefinitionBlockComponent.new(title: 'Décrivez votre projet', can_edit: false) do
      tag.p 'Contenu de la section avec les champs du formulaire.'
    end
  end
end
