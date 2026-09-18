# @label Voile de chargement des statistiques
#
# Voile modal affichant « Chargement des statistiques… » pendant que les chiffres sont récupérés. Il
# porte `role="status"` et `aria-live="polite"` pour que le chargement soit annoncé aux personnes
# qui utilisent un lecteur d’écran.
#
# **Où** : page publique « Statistiques DataPass » (`/stats`), tout en haut du conteneur, au-dessus
# du titre.
#
# **Quand** : il n’y a aucune condition côté Ruby — il est toujours présent dans le HTML, et c’est
# le contrôleur Stimulus `stats` qui l’affiche puis le masque autour des appels à `/stats/data`.
class Organisms::Stats::LoadingOverlayComponentPreview < ApplicationPreview
  # @label 1. Voile pendant le chargement
  #
  # Le voile tel qu’il apparaît le temps d’un appel à `/stats/data`, avec son message « Chargement
  # des statistiques… », son `role="status"` et son `aria-live="polite"`.
  #
  # Aucune condition Ruby ne le masque : il est toujours dans le HTML, affiché puis masqué par le
  # contrôleur Stimulus `stats`. La preview le montre donc en permanence.
  #
  # **Où** : page publique « Statistiques DataPass » (`/stats`), tout en haut du conteneur,
  # au-dessus du titre.
  def default
    render Organisms::Stats::LoadingOverlayComponent.new
  end
end
