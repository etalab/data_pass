# @label Premier bloc de page
#
# Bloc d’ouverture d’une page publique : surtitre, titre, chapô, puis des emplacements facultatifs
# pour les actions, une illustration et un pied.
#
# Deux variantes :
# - `:blue` : fond bleu clair pleine largeur, texte sur toute la largeur (premier écran de l’accueil) ;
# - `:band` : bande bleue, texte sur fond blanc à gauche et illustration à droite (encart
#   « Portefeuille européen » de l’accueil).
#
# L’emplacement `illustration` ne s’affiche que dans la variante `:band` : la variante `:blue`
# l’ignore.
class Organisms::HeroComponentPreview < ApplicationPreview
  # @label 1. Variante bleue (premier écran)
  #
  # Titre en `h1`, chapô et, en pied, la place des tuiles d’orientation.
  #
  # **Où** : premier écran de l’accueil public.
  def blue
    render Organisms::HeroComponent.new(
      variant: :blue,
      kicker: I18n.t('pages.home.hero.kicker'),
      title: I18n.t('pages.home.hero.title'),
      heading: { tag: :h1 }
    ) do |hero|
      hero.with_lead { tag.p(I18n.t('pages.home.hero.lead'), class: 'fr-text--lead') }
    end
  end

  # @label 2. Variante bande, avec illustration
  #
  # Titre en `h2` relié à la section par `aria-labelledby`, bouton d’action et téléphone fictif à
  # droite.
  #
  # **Où** : encart « Portefeuille européen » de l’accueil public.
  def band
    render_with_template(template: 'organisms/hero_component_preview/band')
  end
end
