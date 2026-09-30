# @label Droits non modifiables d’un utilisateur
#
# Section « Droits non modifiables depuis cette interface » : une alerte d’information par type de
# rôle concerné, complétée le cas échéant par la liste des portées visées.
#
# **Où** : espace instruction, page `instruction/user_rights/edit`, dans la section « Les droits »
# du formulaire, au-dessus des droits modifiables.
#
# **Quand** : en modification uniquement ; la page d’ajout (`instruction/user_rights/new`) passe une
# liste vide.
#
# `render?` renvoie `false` quand la liste est vide : le scénario sans droit non modifiable
# n’affiche donc rien du tout dans Lookbook, pas même le titre.
class Molecules::Instruction::UserRights::ReadonlyRightsListComponentPreview < ApplicationPreview
  # @label 1. Droit admin et portées concernées
  #
  # Trois droits non modifiables, dont un droit admin sans portée : une alerte d’information par
  # type de rôle, et la liste des portées visées sous celle qui en a plusieurs.
  #
  # **Où** : espace instruction, modification des droits d’une personne
  # (`instruction/user_rights/edit`), section « Les droits », au-dessus des droits modifiables.
  def with_rights
    render Molecules::Instruction::UserRights::ReadonlyRightsListComponent.new(rights: sample_rights)
  end

  # @label 2. Aucun droit non modifiable (rendu vide)
  #
  # Piège : avec une liste vide, `render?` renvoie `false` et le composant n’affiche rien du tout,
  # pas même le titre. Un aperçu blanc est donc le résultat attendu, pas une preview cassée. C’est
  # aussi le cas de la page d’ajout (`instruction/user_rights/new`), qui passe une liste vide.
  #
  # **Où** : espace instruction, modification des droits d’une personne
  # (`instruction/user_rights/edit`), section « Les droits », au-dessus des droits modifiables.
  def empty
    render Molecules::Instruction::UserRights::ReadonlyRightsListComponent.new(rights: [])
  end

  private

  def sample_rights
    [
      { scope: nil, role_type: 'admin' },
      { scope: 'dinum:api_entreprise', role_type: 'developer' },
      { scope: 'dinum:api_particulier', role_type: 'developer' }
    ]
  end
end
