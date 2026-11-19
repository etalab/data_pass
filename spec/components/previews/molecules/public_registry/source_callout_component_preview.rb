# @label Encart « Source » de la fiche (registre public)
#
# Encart sur fond gris (`fr-background-alt--grey fr-p-3w`) qui dit d’où viennent les informations
# de la fiche et ce que DataPass ne publie pas, avec le lien vers le jeu « Habilitations DataPass
# validées » sur data.gouv.fr, ouvert dans une nouvelle fenêtre (DPP-224, RG3).
#
# **Où** : page publique « Fiche d’une habilitation » du registre public, colonne latérale ; sous
# 992 px, sous la liste des champs.
class Molecules::PublicRegistry::SourceCalloutComponentPreview < ApplicationPreview
  # @label 1. Encart « Source »
  #
  # **Où** : fiche d’une habilitation du registre public.
  def default
    render Molecules::PublicRegistry::SourceCalloutComponent.new
  end
end
