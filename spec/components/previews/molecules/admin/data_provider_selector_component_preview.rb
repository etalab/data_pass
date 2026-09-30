# @label Sélection du fournisseur de données
#
# Liste déroulante des fournisseurs de données, suivie d’un bouton « Ajouter un fournisseur de
# données » qui déplie sur place un formulaire de création.
#
# **Où** : admin > Types d’habilitation > formulaire (création, modification, consultation), tout en
# haut, dans la turbo-frame `data_provider_selection` de
# `Organisms::Admin::HabilitationTypeFormComponent` ; la frame est re-rendue après création d’un
# fournisseur (`admin/data_providers/create`).
#
# **Pour qui** : administratrices et administrateurs uniquement
# (`AdminController#check_user_is_admin!`). Le bouton d’ajout et le formulaire replié disparaissent
# entièrement quand le composant est `disabled`, ce qui arrive en consultation et dès que le type
# porte au moins une demande (`HabilitationTypePolicy#edit_structural_fields?` faux).
#
# La liste déroulante vit hors du formulaire principal : elle lui est rattachée par l’attribut
# `form: 'habilitation-type-form-fields'`, ce qui permet de recharger la frame sans perdre la saisie
# du reste du formulaire.
class Molecules::Admin::DataProviderSelectorComponentPreview < ApplicationPreview
  # @label 1. Liste sans sélection
  #
  # État initial : la liste déroulante est ouverte sur aucun choix et le formulaire d’ajout reste
  # replié derrière son bouton.
  #
  # **Où** : admin > Types d’habilitation > formulaire, tout en haut, dans la turbo-frame
  # `data_provider_selection`. Réservé aux administratrices et administrateurs.
  def default
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all
    )
  end

  # @label 2. Liste avec un fournisseur déjà sélectionné
  #
  # Cas d’une modification : `selected_provider_id` positionne la liste sur le fournisseur du type
  # d’habilitation en cours.
  #
  # **Où** : admin > Types d’habilitation > formulaire, tout en haut, dans la turbo-frame
  # `data_provider_selection`. Réservé aux administratrices et administrateurs.
  def with_selection
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all,
      selected_provider_id: DataProvider.first&.id
    )
  end

  # @label 3. Formulaire d’ajout déplié
  #
  # Après clic sur « Ajouter un fournisseur de données » : le formulaire de création apparaît sous
  # la liste, sans quitter la page.
  #
  # **Où** : admin > Types d’habilitation > formulaire, tout en haut, dans la turbo-frame
  # `data_provider_selection`. Le bouton d’ajout disparaît quand le composant est `disabled`
  # (consultation, ou type portant déjà une demande).
  def with_form_open
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all,
      show_form: true,
      form_data_provider: DataProvider.new
    )
  end

  # @label 4. Formulaire d’ajout déplié avec erreurs de validation
  #
  # Retour d’un envoi refusé : la frame est re-rendue avec le formulaire toujours déplié et ses
  # erreurs, la saisie du reste du formulaire de type d’habilitation étant préservée grâce à
  # l’attribut `form:`.
  #
  # **Où** : admin > Types d’habilitation > formulaire, tout en haut, dans la turbo-frame
  # `data_provider_selection`. Réservé aux administratrices et administrateurs.
  def with_form_errors
    dp = DataProvider.new
    dp.errors.add(:name, :blank)
    render Molecules::Admin::DataProviderSelectorComponent.new(
      data_providers: DataProvider.all,
      show_form: true,
      form_data_provider: dp
    )
  end
end
