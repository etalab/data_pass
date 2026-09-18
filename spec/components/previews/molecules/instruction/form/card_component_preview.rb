# @label Carte d’un cas d’usage
#
# Carte d’un cas d’usage dans la liste des cas d’usage d’un formulaire : pictogramme, nom,
# identifiant, badge « Formulaire par défaut » le cas échéant, puis le nombre de demandes validées
# et soumises.
#
# **Où** : espace instruction, page `instruction/forms/index`, dans la grille filtrée par la barre
# de recherche.
#
# **Quand** : le badge n’apparaît que pour le cas d’usage marqué par défaut sur le formulaire
# (`default`).
#
# Le pictogramme n’est affiché que si un fichier `<use_case>.svg` existe dans
# `app/assets/images/pictograms/authorization_requests/` : le cas d’usage par défaut d’API
# Entreprise (« Demande libre »), qui n’a pas de `use_case`, n’en affiche jamais.
class Molecules::Instruction::Form::CardComponentPreview < ApplicationPreview
  # @label 1. Cas d’usage « Marchés publics »
  #
  # Cas d’usage ordinaire, sans badge : son `use_case` a un pictogramme dédié dans
  # `app/assets/images/pictograms/authorization_requests/`, donc la carte l’affiche.
  #
  # **Où** : espace instruction, liste des cas d’usage d’un formulaire (`instruction/forms/index`),
  # dans la grille filtrée par la barre de recherche.
  def default
    authorization_request_form = AuthorizationDefinition.find('api_entreprise').available_forms.find do |form|
      form.use_case == 'marches_publics'
    end
    render Molecules::Instruction::Form::CardComponent.new(
      authorization_request_form:,
      validated_count: 12,
      submitted_count: 3
    )
  end

  # @label 2. Cas d’usage par défaut, avec son badge
  #
  # Le cas d’usage marqué par défaut sur le formulaire : il gagne le badge « Formulaire par défaut
  # ». Celui d’API Entreprise (« Demande libre ») n’a pas de `use_case`, donc aucun pictogramme
  # n’est affiché ici.
  #
  # **Où** : espace instruction, liste des cas d’usage d’un formulaire (`instruction/forms/index`),
  # dans la grille filtrée par la barre de recherche.
  def default_form
    authorization_request_form = AuthorizationDefinition.find('api_entreprise').default_form
    render Molecules::Instruction::Form::CardComponent.new(
      authorization_request_form:,
      validated_count: 5,
      submitted_count: 1
    )
  end
end
