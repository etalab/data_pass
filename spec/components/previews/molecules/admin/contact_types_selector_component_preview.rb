# @label Choix des types de contacts d’un type d’habilitation
#
# Cases à cocher sur deux colonnes listant les quatre contacts demandables (technique, métier,
# responsable de traitement, délégué à la protection des données).
#
# **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation), section
# « Types de contacts », dans `Organisms::Admin::HabilitationTypeFormComponent`.
#
# **Pour qui** : administratrices et administrateurs uniquement
# (`AdminController#check_user_is_admin!`, `HabilitationTypePolicy`). Le groupe est désactivé quand
# `HabilitationTypePolicy#edit_structural_fields?` est faux, c’est-à-dire dès que le type porte au
# moins une demande.
#
# La section est enveloppée dans le contrôleur Stimulus `blocks-toggle` (`block-name: contacts`) :
# elle n’apparaît que si le bloc « Contacts » est coché plus haut dans le formulaire.
class Molecules::Admin::ContactTypesSelectorComponentPreview < ApplicationPreview
  # @label 1. Tous les types de contacts cochés
  #
  # Cas maximal : les quatre contacts demandables sont cochés (technique, métier, responsable de
  # traitement, délégué à la protection des données), ce qui montre la répartition sur deux
  # colonnes.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Types de contacts », visible
  # seulement si le bloc « Contacts » est coché plus haut (Stimulus `blocks-toggle`).
  def all_checked
    record = HabilitationType.new(
      contact_types: Molecules::Admin::ContactTypesSelectorComponent::CONTACT_TYPES
    )
    render Molecules::Admin::ContactTypesSelectorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Types de contacts'
    )
  end

  # @label 2. Aucun type de contact coché
  #
  # Cas minimal : aucune case cochée, tel qu’à la création d’un type d’habilitation. Sert à vérifier
  # que le groupe reste lisible et que les quatre libellés s’affichent même sans sélection.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Types de contacts », visible
  # seulement si le bloc « Contacts » est coché plus haut (Stimulus `blocks-toggle`).
  def none_checked
    record = HabilitationType.new(contact_types: [])
    render Molecules::Admin::ContactTypesSelectorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Types de contacts'
    )
  end

  # @label 3. Sélection partielle (premier type d’habilitation en base)
  #
  # Cas courant : seuls les contacts réellement demandés par le type sont cochés, à partir d’un
  # enregistrement existant plutôt que d’un objet fabriqué.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Types de contacts », visible
  # seulement si le bloc « Contacts » est coché plus haut (Stimulus `blocks-toggle`).
  def partial_selection
    record = HabilitationType.first
    render Molecules::Admin::ContactTypesSelectorComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Types de contacts'
    )
  end

  private

  def create_form_builder(record)
    DsfrFormBuilder.new(
      :habilitation_type,
      record,
      ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil),
      {}
    )
  end
end
