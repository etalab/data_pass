# @label Filtres des statistiques
#
# Barre de filtrage de la page de statistiques : deux champs de dates « Du … au … inclus », une
# série de boutons de périodes rapides (années, 12 derniers mois, 3 derniers mois, 30 derniers
# jours), deux listes déroulantes fournisseur et API, puis un bouton de réinitialisation.
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), entre le titre et les cartes de
# volume.
#
# Les deux listes déroulantes ne contiennent que l’option « tous » dans le HTML : leurs options
# réelles sont chargées depuis `/stats/filters` par le contrôleur Stimulus `stats`, elles restent
# donc vides en preview.
class Organisms::Stats::FiltersComponentPreview < ApplicationPreview
  # @label 1. Barre de filtrage complète
  #
  # La barre entière : les deux champs de dates « Du … au … inclus », les boutons de périodes
  # rapides, les listes fournisseur et API, et le bouton de réinitialisation.
  #
  # Les deux listes déroulantes ne proposent que l’option « tous » : leurs options réelles sont
  # chargées depuis `/stats/filters` par le contrôleur Stimulus `stats`, absent de la preview.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), entre le titre et les cartes de
  # volume.
  def default
    render Organisms::Stats::FiltersComponent.new
  end
end
