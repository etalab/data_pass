# @label Ligne du tableau de gestion des droits
#
# Une ligne du tableau des droits : email, nom, prénom, badges de droits par portée, puis les boutons
# de modification et de suppression.
#
# **Où** : espace instruction, page `instruction/user_rights/index`, répétée une fois par personne
# dans `Organisms::Instruction::UserRights::TableComponent`.
#
# **Pour qui** : la page est réservée aux managers (`Instruction::UserRightPolicy#index?`) ; les
# boutons d’action ne sont rendus que si `editable?` est vrai.
#
# L’aperçu entoure la ligne d’un `table` et d’un `tbody` : un `tr` seul n’est pas du HTML valide et
# le navigateur ne l’afficherait pas.
class Molecules::Instruction::UserRights::TableRowComponentPreview < ApplicationPreview
  # @label 1. Ligne d’une autre personne
  #
  # La manager API Entreprise voit la ligne de l’instructrice API Entreprise, autre personne de son
  # périmètre : la ligne est `editable?`, donc porte ses boutons de modification et de suppression.
  #
  # **Où** : espace instruction, gestion des droits (`instruction/user_rights/index`), dans le
  # tableau des personnes.
  def other_user_row
    user = User.find_by!(email: 'instructeur-apie@yopmail.com')

    render_in_table(user:, actor: manager)
  end

  # @label 2. Sa propre ligne, sans action possible
  #
  # La manager API Entreprise voit sa propre ligne : `Rights::ManagerAuthority#can_self_edit?`
  # renvoyant toujours `false`, elle apparaît sans aucun bouton d’action.
  #
  # **Où** : espace instruction, gestion des droits (`instruction/user_rights/index`), dans le
  # tableau des personnes.
  def own_row_as_manager
    render_in_table(user: manager, actor: manager)
  end

  private

  def manager
    User.find_by!(email: 'manager-apie@yopmail.com')
  end

  def render_in_table(user:, actor:)
    render_with_template(
      template: 'molecules/instruction/user_rights/table_row_component_preview/in_table',
      locals: { user:, authority: Rights::ManagerAuthority.new(actor), current_user: actor }
    )
  end
end
