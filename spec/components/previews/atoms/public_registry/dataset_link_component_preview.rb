# @label Lien vers le jeu open data (registre public)
#
# Lien DSFR de petite taille vers le jeu « Habilitations DataPass validées » sur data.gouv.fr,
# ouvert dans une nouvelle fenêtre, ce que dit son attribut `title`.
#
# **Où** : registre public, dans l’encart « Source » de la fiche
# (`Molecules::PublicRegistry::SourceCalloutComponent`) et dans l’encart « Télécharger le
# registre » du panneau latéral de la liste.
class Atoms::PublicRegistry::DatasetLinkComponentPreview < ApplicationPreview
  # @label 1. Lien vers data.gouv.fr
  #
  # **Où** : encarts « Source » et « Télécharger le registre » du registre public.
  def default
    render Atoms::PublicRegistry::DatasetLinkComponent.new
  end
end
