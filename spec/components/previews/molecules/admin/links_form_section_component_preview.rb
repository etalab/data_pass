# frozen_string_literal: true

# @label Liens et contact d’un type d’habilitation
#
# Quatre champs sur deux rangées : lien de présentation, lien vers les conditions générales
# d’utilisation, lien d’accès au service et courriel de support.
#
# **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation), section
# « Liens et conditions générales d’utilisation », dans
# `Organisms::Admin::HabilitationTypeFormComponent`.
#
# **Pour qui** : administratrices et administrateurs uniquement
# (`AdminController#check_user_is_admin!`). Ces champs restent éditoriaux : ils ne sont désactivés
# qu’en consultation (`disabled: true`), jamais par le verrouillage structurel lié aux demandes
# existantes.
class Molecules::Admin::LinksFormSectionComponentPreview < ApplicationPreview
  # @label 1. Type d’habilitation existant (premier en base)
  #
  # Les quatre champs préremplis à partir d’un type en base : on y voit la mise en page sur deux
  # rangées avec des valeurs réelles.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Liens et conditions générales
  # d’utilisation ». Champs éditoriaux, désactivés en consultation seulement.
  def default
    record = HabilitationType.first
    render Molecules::Admin::LinksFormSectionComponent.new(
      form: create_form_builder(record)
    )
  end

  # @label 2. Nouveau type d’habilitation, champs vides
  #
  # État à la création : les quatre champs sont vides, ce qui met en avant les libellés et les
  # textes d’aide plutôt que les valeurs.
  #
  # **Où** : admin > Types d’habilitation > formulaire, section « Liens et conditions générales
  # d’utilisation ». Champs éditoriaux, désactivés en consultation seulement.
  def new_record
    record = HabilitationType.new
    render Molecules::Admin::LinksFormSectionComponent.new(
      form: create_form_builder(record)
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
