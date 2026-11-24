# @label Panneau latéral de la liste (registre public)
#
# Panneau `aside` sur fond gris (`fr-background-alt--grey fr-p-3w`) qui porte le filtre « Origine »
# et l’encart « Télécharger le registre ». Affiché à partir de 992 px seulement
# (`fr-hidden fr-unhidden-lg`) : en dessous, l’aperçu est vide, et la page affiche le filtre
# mobile au-dessus de la liste. Le cadre d’aperçu de Lookbook se rétrécit avec sa poignée de
# redimensionnement pour voir ce passage.
#
# **Où** : page publique « Registre public », colonne latérale.
class Organisms::PublicRegistry::SidebarComponentPreview < ApplicationPreview
  # @label 1. Sans filtre choisi
  #
  # **Où** : page publique « Registre public », colonne latérale.
  def default
    render Organisms::PublicRegistry::SidebarComponent.new(url: '#')
  end

  # @label 2. Avec une recherche et un filtre choisi
  #
  # **Où** : page publique « Registre public », colonne latérale.
  def with_selection
    render Organisms::PublicRegistry::SidebarComponent.new(url: '#', origins: ['datapass'], query: 'clamart')
  end
end
