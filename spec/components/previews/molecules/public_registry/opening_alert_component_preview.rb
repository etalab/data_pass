# @label Alerte d’ouverture du registre du portefeuille européen (registre public)
#
# Alerte d’information du DSFR (`DsfrComponent::AlertComponent`) affichée à la place de la liste
# avant l’ouverture du registre du portefeuille européen, quand le filtre « Partie utilisatrice du
# portefeuille européen » est choisi seul, ou quand une recherche sur « portefeuille », « wallet »
# ou « partie utilisatrice » ne donne rien (DPP-223, RG10). La page décide de l’afficher, d’après
# `european_wallet_registry_open?`, le filtre et la recherche. La date d’ouverture est écrite dans
# la clé de traduction du titre.
#
# **Où** : page publique « Registre public », colonne principale, sous le compteur d’entrées.
class Molecules::PublicRegistry::OpeningAlertComponentPreview < ApplicationPreview
  # @label 1. Avant l’ouverture
  #
  # **Où** : page publique « Registre public ».
  def before_opening
    render Molecules::PublicRegistry::OpeningAlertComponent.new(wallet_page_url: '#')
  end
end
