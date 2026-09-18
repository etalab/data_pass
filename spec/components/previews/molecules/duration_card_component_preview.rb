# @label Carte de durée (statistiques)
#
# Carte grise affichant une durée médiane en très gros, surmontée de la mention « 50 % … » et suivie
# de la ligne « 80 % … ». Le libellé change selon le type : « durent moins de » pour une durée de
# remplissage, « au bout de » pour un délai de réponse.
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), dans
# `Organisms::Stats::DurationCardsComponent` qui en affiche trois côte à côte.
#
# Les deux lignes de percentiles portent la classe `fr-hidden` dans le HTML : elles ne sont
# démasquées que par le contrôleur Stimulus `stats`, donc la preview ne les montre pas.
class Molecules::DurationCardComponentPreview < ApplicationPreview
  # @label 1. Durée de remplissage (« durent moins de »)
  #
  # Variante `type: :duration`, titrée « Durée de remplissage d’une nouvelle demande » : les lignes
  # de percentiles se lisent « 50 % durent moins de … ».
  #
  # La médiane reste à « - » et les deux lignes de percentiles portent `fr-hidden` : le contrôleur
  # Stimulus `stats` les démasque et les remplit après l’appel à `/stats/data`.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), dans
  # `Organisms::Stats::DurationCardsComponent` qui en affiche trois côte à côte.
  def duration
    render Molecules::DurationCardComponent.new(
      title: I18n.t('stats.durations.fill_title'),
      percentile_50_target: 'percentile50TimeToSubmit',
      percentile_80_target: 'percentile80TimeToSubmit',
      type: :duration
    )
  end

  # @label 2. Délai de réponse (« au bout de »)
  #
  # Variante `type: :delay`, titrée « Délai de première réponse à une demande » : seule la
  # formulation des percentiles change par rapport au scénario 1, « 50 % au bout de … ».
  #
  # Même piège : médiane à « - » et lignes de percentiles en `fr-hidden` tant que le contrôleur
  # Stimulus `stats` n’a pas tourné.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), dans
  # `Organisms::Stats::DurationCardsComponent` qui en affiche trois côte à côte.
  def delay
    render Molecules::DurationCardComponent.new(
      title: I18n.t('stats.durations.first_response_title'),
      percentile_50_target: 'percentile50TimeToFirstInstruction',
      percentile_80_target: 'percentile80TimeToFirstInstruction',
      type: :delay
    )
  end
end
