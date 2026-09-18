# @label Formulaire de fournisseur de données
#
# Formulaire de création ou de modification d’un fournisseur de données : nom, lien et logo, précédé
# de la liste des erreurs de validation le cas échéant.
#
# **Où** : deux emplacements. En pleine page, sur admin > Fournisseurs de données > « Ajouter » et «
# Modifier » (`admin/data_providers/new` et `edit`). En version compacte (`inline: true`), replié
# dans `Molecules::Admin::DataProviderSelectorComponent`, sous le bouton « Ajouter un fournisseur de
# données » du formulaire de type d’habilitation.
#
# **Pour qui** : administratrices et administrateurs uniquement
# (`AdminController#check_user_is_admin!`, `DataProviderPolicy`).
#
# En version compacte, la validation navigateur est désactivée (`novalidate`) et le formulaire est
# envoyé dans la turbo-frame `data_provider_selection` : les erreurs reviennent dans le bloc replié,
# sans quitter la page. Le libellé du bouton bascule de « Ajouter » à « Modifier » selon que
# l’enregistrement existe déjà.
class Molecules::Admin::DataProviderFormComponentPreview < ApplicationPreview
  # @label 1. Pleine page — création
  #
  # Formulaire vierge, avec le bouton libellé « Ajouter » puisque l’enregistrement n’existe pas
  # encore.
  #
  # **Où** : admin > Fournisseurs de données > « Ajouter » (`admin/data_providers/new`). Réservé aux
  # administratrices et administrateurs.
  def standalone_new
    render Molecules::Admin::DataProviderFormComponent.new(
      data_provider: DataProvider.new
    )
  end

  # @label 2. Pleine page — modification d’un fournisseur existant
  #
  # Mêmes champs, préremplis à partir d’un fournisseur en base ; le bouton bascule de « Ajouter » à
  # « Modifier » puisque l’enregistrement est persisté.
  #
  # **Où** : admin > Fournisseurs de données > « Modifier » (`admin/data_providers/edit`). Réservé
  # aux administratrices et administrateurs.
  def standalone_edit
    render Molecules::Admin::DataProviderFormComponent.new(
      data_provider: DataProvider.first
    )
  end

  # @label 3. Version compacte, dépliée dans le formulaire de type d’habilitation
  #
  # Variante `inline: true` : mise en page resserrée, validation navigateur désactivée
  # (`novalidate`) et envoi dans la turbo-frame `data_provider_selection` pour ne pas quitter la
  # page.
  #
  # **Où** : admin > Types d’habilitation > formulaire, replié sous le bouton « Ajouter un
  # fournisseur de données » de `Molecules::Admin::DataProviderSelectorComponent`.
  def inline
    render Molecules::Admin::DataProviderFormComponent.new(
      data_provider: DataProvider.new,
      inline: true
    )
  end

  # @label 4. Version compacte avec erreurs de validation
  #
  # Même variante compacte après un envoi refusé : la liste des erreurs s’affiche en tête du
  # formulaire, qui revient dans le bloc replié sans rechargement de page.
  #
  # **Où** : admin > Types d’habilitation > formulaire, replié sous le bouton « Ajouter un
  # fournisseur de données » de `Molecules::Admin::DataProviderSelectorComponent`.
  def inline_with_errors
    dp = DataProvider.new
    dp.errors.add(:name, :blank)
    dp.errors.add(:link, :blank)
    render Molecules::Admin::DataProviderFormComponent.new(data_provider: dp, inline: true)
  end
end
