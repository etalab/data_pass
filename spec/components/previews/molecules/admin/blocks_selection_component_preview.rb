# @label Choix des blocs d’un type d’habilitation
#
# Groupe de cases à cocher listant tous les blocs disponibles (`HabilitationType::BLOCK_ORDER`) pour
# composer le formulaire de demande.
#
# **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation), section
# « Blocs », dans `Organisms::Admin::HabilitationTypeFormComponent`.
#
# **Pour qui** : administratrices et administrateurs uniquement
# (`AdminController#check_user_is_admin!`, `HabilitationTypePolicy`). En modification, le groupe est
# désactivé quand `HabilitationTypePolicy#edit_structural_fields?` est faux, c’est-à-dire dès que le
# type porte au moins une demande.
#
# Les cases cochées sont lues via `habilitation_type.ordered_steps`, pas via l’attribut `blocks`
# brut : l’ordre affiché reste celui de `BLOCK_ORDER`.
class Molecules::Admin::BlocksSelectionComponentPreview < ApplicationPreview
  # @label 1. Tous les blocs cochés
  #
  # Cas maximal : toutes les cases de `HabilitationType::BLOCK_ORDER` sont cochées, ce qui donne à
  # voir la liste complète des blocs disponibles et leur ordre d’affichage.
  #
  # **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation),
  # section « Blocs ». Réservé aux administratrices et administrateurs.
  def all_checked
    record = HabilitationType.new(blocks: HabilitationType::BLOCK_ORDER)
    render Molecules::Admin::BlocksSelectionComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Blocs'
    )
  end

  # @label 2. Sélection partielle (premier type d’habilitation en base)
  #
  # Cas courant : seuls les blocs réellement retenus par le type sont cochés. Les cases cochées sont
  # lues via `habilitation_type.ordered_steps`, pas via l’attribut `blocks` brut, donc l’ordre
  # affiché reste celui de `BLOCK_ORDER`.
  #
  # **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation),
  # section « Blocs ». Réservé aux administratrices et administrateurs.
  def partial_selection
    record = HabilitationType.first
    render Molecules::Admin::BlocksSelectionComponent.new(
      form: create_form_builder(record),
      habilitation_type: record,
      title: 'Blocs'
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
