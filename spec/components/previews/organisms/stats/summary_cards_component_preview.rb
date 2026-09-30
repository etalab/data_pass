# @label Cartes de volume (statistiques)
#
# Rangée de trois cartes colorées comptant les demandes sur la période filtrée : soumises (bleu,
# avec le nombre de demandes de mises à jour en sous-titre), validées (vert) et refusées (rouge).
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), juste au-dessus des cartes de durées.
#
# Les compteurs sont écrits en dur à « - » dans le HTML et remplis ensuite par le contrôleur
# Stimulus `stats`, donc la preview les laisse à « - ».
class Organisms::Stats::SummaryCardsComponentPreview < ApplicationPreview
  # @label 1. Les trois cartes de volume
  #
  # La rangée complète : demandes soumises en bleu (avec le sous-titre « dont N demandes de mises à
  # jour »), validées en vert, refusées en rouge.
  #
  # Les compteurs restent à « - » : ils sont écrits en dur dans le HTML et remplis par le contrôleur
  # Stimulus `stats` après l’appel à `/stats/data`, qui ne tourne pas ici.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), juste au-dessus des cartes de
  # durées.
  def default
    render Organisms::Stats::SummaryCardsComponent.new
  end
end
