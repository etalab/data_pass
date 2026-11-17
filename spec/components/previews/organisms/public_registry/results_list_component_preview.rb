# @label Liste des résultats (registre public)
#
# Liste des tuiles d’habilitation du registre public : une grille DSFR sans puces
# (`ul.fr-grid-row.fr-grid-row--gutters.fr-raw-list`), une tuile pleine largeur par `li.fr-col-12`.
# Chaque tuile s’ajoute avec `with_tile(url:, entry:, origin:)`, qui prend les paramètres de
# `Molecules::PublicRegistry::AuthorizationTileComponent`.
#
# **Où** : page publique « Registre public », dans la colonne principale, sous le compteur
# d’entrées. Sans tuile, le composant n’affiche rien : la page affiche alors le message de liste
# vide ou l’alerte d’ouverture.
class Organisms::PublicRegistry::ResultsListComponentPreview < ApplicationPreview
  # @label 1. Trois habilitations
  #
  # Trois habilitations de fournisseurs et d’organisations différents, dont une entreprise.
  #
  # **Où** : page publique « Registre public », colonne principale.
  def three_results
    render Organisms::PublicRegistry::ResultsListComponent.new do |list|
      list.with_tile(url: '#', entry: Molecules::PublicRegistry::AuthorizationEntry.new(denomination: 'Ville de Clamart', service: 'APIParticulier', provider: 'DINUM', validated_on: Date.new(2026, 7, 2), number: 'H44120'))
      list.with_tile(url: '#', entry: Molecules::PublicRegistry::AuthorizationEntry.new(denomination: 'Département du Rhône', service: 'APIImpotParticulier', provider: 'DGFIP', validated_on: Date.new(2026, 4, 4), number: 'H42305'))
      list.with_tile(url: '#', entry: Molecules::PublicRegistry::AuthorizationEntry.new(denomination: 'MGDIS', service: 'FranceConnect', provider: 'DINUM', validated_on: Date.new(2026, 6, 23), number: 'H43517'))
    end
  end
end
