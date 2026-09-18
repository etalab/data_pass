# @label Ligne de saisie d’un droit
#
# Ligne du formulaire de droits : la liste déroulante « Portée des droits », la liste déroulante «
# Rôle » et le bouton « Supprimer ce droit ».
#
# **Où** : espace instruction, pages `instruction/user_rights/new` et
# `instruction/user_rights/edit`, dans la section « Les droits », répétée une fois par droit. **Pour
# qui** : le contenu des deux listes dépend de l’autorité passée en `permissions` —
# `Rights::ManagerAuthority` n’expose que les services gérés par la personne connectée, et l’option
# « Tous les services X » n’apparaît que si elle est manager du fournisseur de données
# (`fd_manager_for?`).
#
# La légende du `fieldset` est en `fr-sr-only` : destinée aux lecteurs d’écran, elle reste invisible
# à l’écran dans la preview.
class Molecules::Instruction::UserRights::RightFieldComponentPreview < ApplicationPreview
  # @label 1. Ligne vierge (ajout d’un droit)
  #
  # État initial d’une ligne : les deux listes déroulantes sont sur leur option vide. L’autorité
  # passée est celle d’une personne manager de définitions, donc sans option « Tous les services X
  # ».
  #
  # **Où** : espace instruction, ajout ou modification des droits d’une personne
  # (`instruction/user_rights/new` et `edit`), section « Les droits », une fois par droit.
  def empty
    render Molecules::Instruction::UserRights::RightFieldComponent.new(
      index: 0,
      scope: '',
      role_type: '',
      permissions: definition_manager_permissions
    )
  end

  # @label 2. Ligne préremplie (manager d’un fournisseur)
  #
  # Ligne existante, portée et rôle déjà sélectionnés, vue par une personne manager du fournisseur
  # de données DGFiP : c’est le seul scénario où l’option « Tous les services X » apparaît dans la
  # liste des portées (`fd_manager_for?`), et la liste s’y limite aux formulaires DGFiP.
  #
  # **Où** : espace instruction, ajout ou modification des droits d’une personne
  # (`instruction/user_rights/new` et `edit`), section « Les droits », une fois par droit.
  def filled
    render Molecules::Instruction::UserRights::RightFieldComponent.new(
      index: 1,
      scope: 'dinum:api_entreprise',
      role_type: 'manager',
      permissions: fd_manager_permissions
    )
  end

  # @label 3. Gabarit cloné à l’ajout d’une ligne
  #
  # Le gabarit avec l’index `NEW`, celui que le JavaScript duplique au clic sur « Ajouter un droit »
  # en y substituant un vrai index. À l’écran il ressemble au scénario 1 : ce qui change, ce sont
  # les `id` des champs et la légende du `fieldset`, en `fr-sr-only` donc invisible hors lecteur
  # d’écran.
  #
  # **Où** : espace instruction, ajout ou modification des droits d’une personne
  # (`instruction/user_rights/new` et `edit`), section « Les droits », une fois par droit.
  def nested_form_template
    render Molecules::Instruction::UserRights::RightFieldComponent.new(
      index: 'NEW',
      scope: '',
      role_type: '',
      permissions: definition_manager_permissions
    )
  end

  private

  def definition_manager_permissions
    Rights::ManagerAuthority.new(User.find_by!(email: 'datapass@yopmail.com'))
  end

  def fd_manager_permissions
    Rights::ManagerAuthority.new(User.find_by!(email: 'dgfip@yopmail.com'))
  end
end
