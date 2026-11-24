# @label Encart « Télécharger le registre » (registre public)
#
# Titre, texte sur la publication en open data (article L114-8 du code des relations entre le
# public et l’administration, mise à jour le 1er de chaque mois) et lien vers le jeu sur
# data.gouv.fr (DPP-223, RG6). Sans fond propre : il prend celui du panneau latéral.
#
# **Où** : page publique « Registre public », panneau latéral, sous le filtre « Origine ». Pas
# repris sous 992 px.
class Molecules::PublicRegistry::DownloadCalloutComponentPreview < ApplicationPreview
  # @label 1. Encart « Télécharger le registre »
  #
  # **Où** : page publique « Registre public », panneau latéral.
  def default
    render Molecules::PublicRegistry::DownloadCalloutComponent.new
  end
end
