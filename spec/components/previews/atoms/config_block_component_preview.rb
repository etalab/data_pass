# @label Bloc « Configuration »
#
# Encart au titre fixe « Configuration », composé d’une liste de définitions (libellé à gauche,
# valeur à droite) qui récapitule les réglages d’un objet. Les valeurs booléennes y prennent la
# forme d’un badge vert ou neutre.
#
# **Où** : espace instruction, sur deux pages de consultation, chacune passant par une sous-classe
# qui construit ses propres lignes — `instruction/forms/show` via
# `Molecules::Instruction::Form::ConfigBlockComponent` (fournisseur de service, public, démarrable
# par le demandeur, vue sur une seule page) et `instruction/authorization_definitions/show` via
# `Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent` (nature, unicité,
# messagerie, transfert, réouverture, brouillons instructeurs, courriel de support, lien d’accès).
#
# Le composant de base n’est jamais rendu directement dans le produit : le titre vient toujours de
# la traduction `atoms.config_block_component.title` et les lignes sont fournies par la sous-classe.
# Les lignes de cette prévisualisation sont donc fabriquées à la main et ne correspondent à aucune
# page réelle.
class Atoms::ConfigBlockComponentPreview < ApplicationPreview
  # @label 1. Trois lignes : texte, badge booléen et courriel
  #
  # Scénario unique, qui montre les trois formes de valeur que l’encart sait rendre : texte mis en
  # avant, badge booléen et lien de courriel. Attention : le composant de base n’étant jamais rendu
  # directement dans le produit, ces lignes sont fabriquées à la main et ne correspondent à aucune
  # page réelle.
  #
  # **Où** : espace instruction, sur `instruction/forms/show` et
  # `instruction/authorization_definitions/show`, toujours via une sous-classe qui construit ses
  # propres lignes.
  def default
    render Atoms::ConfigBlockComponent.new(
      rows: [
        { label: 'Type', value: tag.strong('Production') },
        { label: 'Activé', value: tag.span('Oui', class: 'config-block__badge config-block__badge--success') },
        { label: 'Email support', value: mail_to('support@example.com', 'support@example.com', class: 'fr-link') }
      ]
    )
  end
end
