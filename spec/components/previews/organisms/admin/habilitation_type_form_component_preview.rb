# @label Formulaire complet d’un type d’habilitation
#
# Formulaire d’administration d’un type d’habilitation, du choix du fournisseur de données jusqu’aux
# boutons d’envoi : informations générales, nature (API ou service), liens, blocs du formulaire de
# demande, données (scopes) et types de contacts.
#
# **Où** : admin > Types d’habilitation, sur les trois pages `admin/habilitation_types/new`, `edit`
# et `show`.
#
# **Pour qui** : administratrices et administrateurs uniquement
# (`AdminController#check_user_is_admin!`, `HabilitationTypePolicy`).
#
# Trois états d’édition, pilotés par l’argument `disabled`. En consultation (`show`), `disabled:
# true` : tout est figé et les boutons d’envoi disparaissent. En modification (`edit`), la vue passe
# `:structural` dès que `HabilitationTypePolicy#edit_structural_fields?` est faux, c’est-à-dire dès
# que le type porte au moins une demande : la nature, les blocs, les types de contacts et la valeur
# des scopes se verrouillent, mais le nom, la description, les liens et les libellés de scopes
# restent modifiables. Sinon, le formulaire est entièrement ouvert. Les sections « Données (scopes)
# » et « Types de contacts » ne s’affichent en plus que si le bloc correspondant est coché
# (contrôleur Stimulus `blocks-toggle`).
class Organisms::Admin::HabilitationTypeFormComponentPreview < ApplicationPreview
  # @label 1. Création — tous les blocs cochés
  #
  # Formulaire entièrement ouvert et vierge, avec tous les blocs cochés : c’est le seul scénario où
  # les sections « Données (scopes) » et « Types de contacts » sont toutes deux dépliées.
  #
  # **Où** : admin > Types d’habilitation > `new`. Réservé aux administratrices et administrateurs.
  def new_record
    render Organisms::Admin::HabilitationTypeFormComponent.new(
      habilitation_type: HabilitationType.new(blocks: HabilitationType::BLOCK_ORDER)
    )
  end

  # @label 2. Modification d’un type existant (premier en base)
  #
  # Formulaire prérempli à partir d’un type en base, sans argument `disabled` : il est donc rendu
  # ouvert ici, alors qu’en modification réelle la vue passe `:structural` dès que le type porte au
  # moins une demande.
  #
  # **Où** : admin > Types d’habilitation > `edit` (et `show`, où `disabled: true` fige tout et
  # retire les boutons d’envoi). Réservé aux administratrices et administrateurs.
  def existing_record
    render Organisms::Admin::HabilitationTypeFormComponent.new(
      habilitation_type: HabilitationType.first
    )
  end
end
