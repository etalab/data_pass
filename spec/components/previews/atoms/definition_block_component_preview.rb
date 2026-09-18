# @label Bloc d’aperçu d’une étape de formulaire
#
# Encadré titré montrant à quoi ressemble une étape du formulaire de demande. La variante « étape
# masquée » ajoute au titre un badge à l’œil barré et raye l’aperçu, pour signaler une étape que le
# demandeur ne verra pas.
#
# **Où** : espace instruction, page de configuration d’un cas d’usage (`instruction/forms/show`) et
# page des étapes d’une API (`instruction/authorization_definition_blocks/show`), un bloc par étape.
#
# L’aperçu est enfermé dans un conteneur `inert` : rien n’y est cliquable ni saisissable, c’est
# volontairement une image figée du formulaire.
class Atoms::DefinitionBlockComponentPreview < ApplicationPreview
  # @label 1. Étape présentée au demandeur
  #
  # L’encadré ordinaire : un titre et l’aperçu de l’étape, ici réduit à un paragraphe. L’aperçu est
  # enfermé dans un conteneur `inert`, donc rien n’y est cliquable ni saisissable.
  #
  # **Où** : espace instruction, pages de configuration d’un cas d’usage (`instruction/forms/show`)
  # et des étapes d’une API (`instruction/authorization_definition_blocks/show`), un bloc par étape.
  def default
    render Atoms::DefinitionBlockComponent.new(title: 'Décrivez votre projet') do
      tag.p 'Contenu de la section avec les champs du formulaire.'
    end
  end

  # @label 2. Étape masquée au demandeur
  #
  # La variante `static_block: true` : le titre reçoit un badge à l’œil barré et l’aperçu est rayé,
  # pour signaler une étape que le demandeur ne verra pas dans son formulaire.
  #
  # **Où** : espace instruction, pages de configuration d’un cas d’usage (`instruction/forms/show`)
  # et des étapes d’une API (`instruction/authorization_definition_blocks/show`), un bloc par étape.
  def static_block
    render Atoms::DefinitionBlockComponent.new(title: 'Décrivez votre projet', static_block: true) do
      tag.p 'Contenu de la section avec les champs du formulaire.'
    end
  end
end
