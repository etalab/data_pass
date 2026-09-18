# @label Transcription d’un graphique
#
# Bouton « Transcription » dépliant la description textuelle d’un graphique, avec un bouton «
# Agrandir » qui rouvre cette description dans une modale. C’est l’équivalent accessible du
# graphique, pour les personnes qui ne peuvent pas lire le `<canvas>`.
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), sous le graphique d’évolution, rendu
# par `Organisms::Stats::TimeSeriesChartComponent`.
#
# Le paramètre `id` sert à fabriquer tous les identifiants du composant (`transcription-<id>`, la
# modale et son titre) : deux transcriptions partageant le même `id` sur une page casseraient les
# liens `aria-controls`.
class Organisms::Stats::TranscriptionComponentPreview < ApplicationPreview
  # @label 1. Transcription du graphique d’évolution
  #
  # Le composant seul, alimenté avec le titre et la description du graphique d’évolution : bouton «
  # Transcription » qui déplie le texte, et bouton « Agrandir » qui le rouvre en modale.
  #
  # L’`id` passé ici (« preview ») fabrique tous les identifiants du composant : deux transcriptions
  # partageant le même `id` sur une page casseraient les liens `aria-controls`.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), sous le graphique d’évolution,
  # rendu par `Organisms::Stats::TimeSeriesChartComponent`.
  def default
    render Organisms::Stats::TranscriptionComponent.new(
      id: 'preview',
      title: I18n.t('stats.chart.transcription_title'),
      description: I18n.t('stats.chart.transcription_description')
    )
  end
end
