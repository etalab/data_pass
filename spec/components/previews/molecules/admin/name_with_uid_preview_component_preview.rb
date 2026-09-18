# @label Nom et aperçu de l’identifiant technique
#
# Champ « Nom » accompagné de l’identifiant technique (UID) : à la création, l’identifiant se
# construit en direct pendant la frappe ; sur un enregistrement existant, il est simplement affiché,
# figé.
#
# **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation), section
# « Informations générales », dans `Organisms::Admin::HabilitationTypeFormComponent`.
#
# **Quand** : deux rendus distincts selon `record.persisted?` — création, avec l’aperçu piloté par
# le contrôleur Stimulus `name-with-uid-preview` ; ou enregistrement existant, où l’UID déjà
# attribué s’affiche en texte d’aide et n’est plus modifiable.
#
# L’aperçu est annoncé aux lectrices et lecteurs d’écran via `aria-live="polite"` et
# `aria-atomic="true"` : la zone se relit en entier à chaque frappe.
class Molecules::Admin::NameWithUidPreviewComponentPreview < ApplicationPreview
  # @label 1. Création — aperçu de l’identifiant en direct
  #
  # Enregistrement non persisté : l’identifiant technique se construit pendant la frappe (contrôleur
  # Stimulus `name-with-uid-preview`), dans une zone `aria-live="polite"` et `aria-atomic="true"`
  # relue en entier à chaque changement.
  #
  # **Où** : admin > Types d’habilitation > formulaire de création, section « Informations générales
  # ».
  def new_record
    record = HabilitationType.new
    render Molecules::Admin::NameWithUidPreviewComponent.new(
      form: create_form_builder(record),
      record: record,
      uid_label: 'Identifiant technique'
    )
  end

  # @label 2. Enregistrement existant — identifiant figé
  #
  # Enregistrement persisté : l’UID déjà attribué s’affiche en texte d’aide, sans aperçu dynamique,
  # et n’est plus modifiable.
  #
  # **Où** : admin > Types d’habilitation > formulaire de modification ou de consultation, section «
  # Informations générales ».
  def existing_record
    record = HabilitationType.first
    render Molecules::Admin::NameWithUidPreviewComponent.new(
      form: create_form_builder(record),
      record: record,
      uid_label: 'Identifiant technique'
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
