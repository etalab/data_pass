# @label Pictogramme DSFR
#
# Pictogramme du DSFR en trois calques (décoratif, mineur, majeur), servi par la gem `dsfr-assets`.
# Il est décoratif : `aria-hidden`, sans texte alternatif.
#
# **Où** : accueil public (tuiles, exemples de demandes, groupes « Ce que DataPass permet ») et
# pages d’erreur, avec le fond ovoïde.
class Atoms::PictogramComponentPreview < ApplicationPreview
  # @label 1. Pictogramme seul
  #
  # Taille par défaut de 80 px, comme dans les tuiles du premier écran de l’accueil.
  def default
    render Atoms::PictogramComponent.new(name: 'digital/search')
  end

  # @label 2. Petite taille
  #
  # Même pictogramme à 56 px.
  def small
    render Atoms::PictogramComponent.new(name: 'buildings/city-hall', size: 56)
  end

  # @label 3. Avec le fond ovoïde
  #
  # Le pictogramme posé sur le fond ovoïde du DSFR, en 160 × 200 px.
  #
  # **Où** : pages d’erreur.
  def with_ovoid_background
    render Atoms::PictogramComponent.new(name: 'system/technical-error', background: :ovoid)
  end
end
