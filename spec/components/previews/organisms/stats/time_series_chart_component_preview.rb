# @label Graphique d’évolution des demandes
#
# Carte blanche contenant le graphique d’évolution des demandes en attente de réponse, immédiatement
# suivie de sa transcription dépliable.
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), sous le titre « Évolution des
# demandes en attente de réponse ».
#
# Le graphique est un `<canvas>` vide dessiné par le contrôleur Stimulus `stats` : en preview, seuls
# la carte et la transcription sont visibles, pas les courbes.
class Organisms::Stats::TimeSeriesChartComponentPreview < ApplicationPreview
  # @label 1. Carte du graphique et sa transcription
  #
  # La carte blanche du graphique d’évolution des demandes en attente de réponse, suivie de sa
  # transcription dépliable.
  #
  # Le graphique lui-même est un `<canvas>` vide, dessiné par le contrôleur Stimulus `stats` : la
  # preview montre la carte et la transcription, jamais les courbes.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), sous le titre « Évolution des
  # demandes en attente de réponse ».
  def default
    render Organisms::Stats::TimeSeriesChartComponent.new
  end
end
