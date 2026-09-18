# @label Badge coloré de rôle
#
# Badge DSFR sans icône, d’une couleur propre à chaque rôle, qui étiquette le rôle d’une personne
# sur un périmètre donné.
#
# **Où** : espace instruction, gestion des droits. Dans le tableau des personnes
# (`Molecules::Instruction::UserRights::TableRowComponent`), un badge par rôle et par périmètre ; et
# dans la fenêtre de confirmation de retrait des droits
# (`instruction/user_rights/_confirm_destroy`), pour récapituler les rôles sur le point d’être
# supprimés.
#
# Dans le produit, le composant n’est appelé que par `Atoms::ColorBadgeComponent.for_role`, qui
# impose la couleur via la table `ROLE_COLORS` et laisse la taille par défaut (`sm`) : les couleurs
# ne sont donc jamais choisies au cas par cas. Le constructeur refuse toute couleur hors de
# `ALLOWED_COLORS` et toute taille hors de `ALLOWED_SIZES`.
class Atoms::ColorBadgeComponentPreview < ApplicationPreview
  # @label 1. Rôle « Manager »
  #
  # Couleur `purple-glycine`, imposée par la table `ROLE_COLORS` pour le rôle de gestion des droits.
  #
  # **Où** : espace instruction, gestion des droits — tableau des personnes et fenêtre de
  # confirmation de retrait des droits.
  def role_manager
    render Atoms::ColorBadgeComponent.new(label: 'Manager', color: 'purple-glycine')
  end

  # @label 2. Rôle « Instructeur »
  #
  # Couleur `pink-tuile`, imposée par la table `ROLE_COLORS` pour le rôle qui instruit les demandes.
  #
  # **Où** : espace instruction, gestion des droits — tableau des personnes et fenêtre de
  # confirmation de retrait des droits.
  def role_instructor
    render Atoms::ColorBadgeComponent.new(label: 'Instructeur', color: 'pink-tuile')
  end

  # @label 3. Rôle « Observateur »
  #
  # Couleur `yellow-tournesol`, imposée par la table `ROLE_COLORS` pour le rôle en lecture seule.
  #
  # **Où** : espace instruction, gestion des droits — tableau des personnes et fenêtre de
  # confirmation de retrait des droits.
  def role_reporter
    render Atoms::ColorBadgeComponent.new(label: 'Observateur', color: 'yellow-tournesol')
  end

  # @label 4. Rôle « Développeur »
  #
  # Couleur `blue-ecume`, imposée par la table `ROLE_COLORS` pour le rôle qui accède à l’espace
  # développeurs.
  #
  # **Où** : espace instruction, gestion des droits — tableau des personnes et fenêtre de
  # confirmation de retrait des droits.
  def role_developer
    render Atoms::ColorBadgeComponent.new(label: 'Développeur', color: 'blue-ecume')
  end

  # @label 5. Taille moyenne (variante non utilisée dans le produit)
  #
  # Seul scénario à forcer `size: :md`. Attention : dans le produit, le composant n’est appelé que
  # par `Atoms::ColorBadgeComponent.for_role`, qui laisse la taille par défaut (`sm`) — cette
  # variante n’apparaît donc nulle part.
  #
  # **Où** : nulle part en l’état ; les badges réels sont ceux de l’espace instruction, gestion des
  # droits.
  def size_md
    render Atoms::ColorBadgeComponent.new(label: 'Manager', color: 'purple-glycine', size: :md)
  end
end
