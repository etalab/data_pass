# @label Mise en page à deux colonnes (registre public)
#
# Grille DSFR à deux colonnes (`fr-grid-row fr-grid-row--gutters`) : colonne principale en
# `fr-col-12 fr-col-lg-8`, colonne latérale en `fr-col-12 fr-col-lg-4`. Sous 992 px (point `lg`
# du DSFR), une seule colonne : la colonne latérale passe sous la principale. Le contenu se passe
# par les emplacements `with_main` et `with_aside` ; sans `with_aside`, seule la colonne
# principale est rendue.
#
# **Où** : pages publiques « Registre public » (tuiles à gauche, panneau latéral à droite) et
# « Fiche d’une habilitation » (champs à gauche, encart « Source » à droite).
class Organisms::PublicRegistry::TwoColumnLayoutComponentPreview < ApplicationPreview
  # @label 1. Liste : tuiles et panneau latéral
  #
  # Sous 992 px, le panneau latéral n’est pas affiché : le filtre « Origine » mobile passe
  # au-dessus de la liste, et l’encart « Télécharger le registre » n’est pas repris.
  #
  # **Où** : page publique « Registre public ».
  def list
    render_with_template(template: 'organisms/public_registry/two_column_layout_component_preview/list')
  end

  # @label 2. Fiche : champs et encart « Source »
  #
  # Sous 992 px, l’encart « Source » passe sous la liste des champs.
  #
  # **Où** : page publique « Fiche d’une habilitation ».
  def authorization
    render_with_template(template: 'organisms/public_registry/two_column_layout_component_preview/authorization')
  end
end
