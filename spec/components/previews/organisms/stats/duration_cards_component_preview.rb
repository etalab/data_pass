# @label Cartes de durées (statistiques)
#
# Rangée de trois cartes grises affichant les durées et délais constatés : durée de remplissage
# d’une nouvelle demande, délai de première réponse, délai de réponse définitive. Chaque carte
# montre la valeur médiane en grand et le 80e percentile en dessous.
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), sous les cartes de volume.
#
# Les trois valeurs sont écrites en dur à « - » dans le HTML : c’est le contrôleur Stimulus `stats`
# qui les remplace après l’appel à `/stats/data`, donc la preview les laisse à « - ».
class Organisms::Stats::DurationCardsComponentPreview < ApplicationPreview
  # @label 1. Les trois cartes de durées
  #
  # La rangée complète : durée de remplissage d’une nouvelle demande, délai de première réponse,
  # délai de réponse définitive, chacune avec sa médiane en très gros.
  #
  # Les trois valeurs restent à « - » : elles sont écrites en dur dans le HTML et remplacées par le
  # contrôleur Stimulus `stats` après l’appel à `/stats/data`, qui ne tourne pas ici.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), sous les cartes de volume.
  def default
    render Organisms::Stats::DurationCardsComponent.new
  end
end
