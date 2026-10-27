# @label Menu de l’espace instruction
#
# Entrées du menu principal de l’en-tête dans l’espace instruction : « Demandes / habilitations »
# en premier, puis les pages auxquelles la personne connectée a accès.
#
# **Où** : en-tête de toutes les pages de l’espace instruction, dans le partiel
# `layouts/header/_menu`, à l’intérieur de la liste `fr-nav__list` (`namespace?(:instruction)`).
#
# **Quand** : chaque entrée dépend d’une politique d’accès, calculée dans le partiel :
# - « Formulaires » : drapeau de fonctionnalité `authorization_definitions` activé pour la personne
#   (`authorization_definitions_feature_enabled?`) et rôle de lecteur ou administrateur (`reporter?`, via
#   `policy([:instruction, :authorization_definition]).index?`) ;
# - brouillons instructeur : instructeur d’au moins un type de demande où les brouillons
#   instructeur sont activés (`policy([:instruction, :instructor_draft_request]).enabled?`) ;
# - modèles de messages : instructeur ou manager (`policy([:instruction, :message_template]).index?`) ;
# - gestion des droits : manager (`policy([:instruction, :user_right]).index?`).
#
# Si aucune n’est vraie, le composant ne rend rien, pas même « Demandes / habilitations »
# (`render?`).
#
# Le composant ne rend que les éléments `li` : l’aperçu les place dans l’enveloppe `nav` et `ul` du
# partiel, sans laquelle le HTML serait invalide.
class Atoms::InstructorMenuComponentPreview < ApplicationPreview
  # @label 1. Menu complet
  #
  # Toutes les entrées, dans l’ordre réel : vue d’une personne manager et lectrice, instructrice
  # d’un type de demande à brouillons instructeur, avec la fonctionnalité « Formulaires » activée.
  #
  # **Où** : en-tête de l’espace instruction.
  def full
    render_in_navigation(show_definitions: true, show_drafts: true, show_templates: true, show_user_rights: true)
  end

  # @label 2. Menu réduit
  #
  # Une seule page accessible en plus de « Demandes / habilitations » : les modèles de messages.
  # Vue d’une personne instructrice, non manager, sans brouillons instructeur ni fonctionnalité
  # « Formulaires ».
  #
  # **Où** : en-tête de l’espace instruction.
  def templates_only
    render_in_navigation(show_definitions: false, show_drafts: false, show_templates: true, show_user_rights: false)
  end

  private

  def render_in_navigation(**flags)
    render_with_template(
      template: 'atoms/instructor_menu_component_preview/in_navigation',
      locals: { flags: }
    )
  end
end
