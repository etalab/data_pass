# @label Tableau de gestion des droits
#
# Tableau listant les personnes ayant des droits dans le périmètre de la personne connectée : email,
# nom, prénom, badges de droits par portée, puis les actions de modification et de suppression.
#
# **Où** : espace instruction, page `instruction/user_rights/index`, à l’intérieur de la turbo-frame
# alimentée par la recherche.
#
# **Pour qui** : la page est réservée aux managers (`Instruction::UserRightPolicy#index?`) ; les
# boutons d’action d’une ligne ne sont rendus que si `editable?` est vrai.
#
# `Rights::ManagerAuthority#can_self_edit?` renvoie toujours `false` : la ligne de la personne
# connectée apparaît donc sans aucun bouton d’action.
class Organisms::Instruction::UserRights::TableComponentPreview < ApplicationPreview
  # @label 1. Cinq utilisateurs du périmètre
  #
  # Tableau peuplé de cinq personnes autres que celle connectée : chaque ligne est `editable?`, donc
  # porte ses boutons de modification et de suppression.
  #
  # **Où** : espace instruction, gestion des droits (`instruction/user_rights/index`), dans la
  # turbo-frame alimentée par la recherche.
  def with_users
    actor = User.find_by!(email: 'datapass@yopmail.com')
    users = User.with_roles.where.not(id: actor.id).limit(5)

    render Organisms::Instruction::UserRights::TableComponent.new(
      users: users,
      authority: Rights::ManagerAuthority.new(actor),
      current_user: actor,
      total_count: users.size
    )
  end

  # @label 2. Sa propre ligne, sans action possible
  #
  # La personne connectée est en première ligne du tableau :
  # `Rights::ManagerAuthority#can_self_edit?` renvoyant toujours `false`, sa ligne apparaît sans
  # aucun bouton d’action, contrairement aux suivantes.
  #
  # **Où** : espace instruction, gestion des droits (`instruction/user_rights/index`), dans la
  # turbo-frame alimentée par la recherche.
  def with_own_row_non_editable_as_manager
    actor = User.find_by!(email: 'datapass@yopmail.com')
    others = User.with_roles.where.not(id: actor.id).limit(4).to_a
    users = [actor, *others]

    render Organisms::Instruction::UserRights::TableComponent.new(
      users: users,
      authority: Rights::ManagerAuthority.new(actor),
      current_user: actor,
      total_count: users.size
    )
  end
end
