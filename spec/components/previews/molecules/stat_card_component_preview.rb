# @label Carte de volume (statistiques)
#
# Carte de couleur affichant un compteur en très gros sous son intitulé, avec une ligne facultative
# « dont N demandes de mises à jour ». Les couleurs de fond et de chiffre sont passées par le
# composant parent.
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), dans
# `Organisms::Stats::SummaryCardsComponent` qui en affiche trois : soumises, validées, refusées.
#
# Le compteur est écrit en dur à « - » dans le HTML et rempli par le contrôleur Stimulus `stats`,
# donc la preview le laisse à « - ».
class Molecules::StatCardComponentPreview < ApplicationPreview
  # @label 1. Carte simple (demandes validées)
  #
  # La carte sans sous-titre : un intitulé, un compteur, et les couleurs vertes passées par le
  # composant parent pour les demandes validées.
  #
  # Le compteur reste à « - » : il est écrit en dur dans le HTML et rempli par le contrôleur
  # Stimulus `stats` après l’appel à `/stats/data`, qui ne tourne pas ici.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), dans
  # `Organisms::Stats::SummaryCardsComponent` qui en affiche trois : soumises, validées, refusées.
  def default
    render Molecules::StatCardComponent.new(
      title: I18n.t('stats.summary.validated'),
      target: 'validationsCount',
      style: {
        card_classes: 'fr-background-contrast--green-emeraude',
        value_classes: 'fr-text-default--success',
        col_classes: 'fr-col-12 fr-col-md-6 fr-col-lg-4'
      }
    )
  end

  # @label 2. Carte avec sous-titre (demandes soumises)
  #
  # La même carte en bleu, avec en plus la ligne « dont N demandes de mises à jour » qu’ouvre le
  # `subtitle_target` : c’est la seule différence avec le scénario 1.
  #
  # Les deux chiffres restent à « - » tant que le contrôleur Stimulus `stats` n’a pas tourné.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), dans
  # `Organisms::Stats::SummaryCardsComponent` qui en affiche trois : soumises, validées, refusées.
  def with_subtitle
    render Molecules::StatCardComponent.new(
      title: I18n.t('stats.summary.submitted'),
      target: 'totalRequestsCount',
      subtitle_target: 'reopeningsCount',
      style: {
        card_classes: 'fr-background-contrast--blue-france',
        value_classes: 'fr-text-action-high--blue-france',
        col_classes: 'fr-col-12 fr-col-md-6 fr-col-lg-4'
      }
    )
  end
end
