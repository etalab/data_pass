# @label Filtre « Origine » (registre public)
#
# Tags sélectionnables du DSFR (`DsfrComponent::TagComponent` avec `selected:`), chacun bouton
# d’envoi d’un formulaire GET à part, qui garde la recherche en champ caché `q`. La valeur de
# chaque bouton est la sélection obtenue après le clic : `datapass`, `portefeuille-europeen`,
# `datapass,portefeuille-europeen`, ou vide si plus rien n’est choisi. La page rechargée lit
# `origine` dans l’adresse et passe la sélection en `origins:`.
#
# Deux emplacements (`placement:`) : `:sidebar`, titre `h2` dans le panneau latéral ; `:mobile`,
# au-dessus de la liste, affiché seulement sous 992 px.
#
# **Où** : page publique « Registre public » (DPP-223, RG10).
class Molecules::PublicRegistry::OriginFilterComponentPreview < ApplicationPreview
  # @label 1. Aucun choix
  #
  # **Où** : page publique « Registre public », panneau latéral.
  def none_selected
    render Molecules::PublicRegistry::OriginFilterComponent.new(url: '#', placement: :sidebar)
  end

  # @label 2. « Habilitation DataPass » choisi
  #
  # **Où** : page publique « Registre public », panneau latéral.
  def datapass_selected
    render Molecules::PublicRegistry::OriginFilterComponent.new(url: '#', placement: :sidebar, origins: ['datapass'], query: 'clamart')
  end

  # @label 3. « Partie utilisatrice du portefeuille européen » choisi
  #
  # Avant l’ouverture du registre du portefeuille européen, la page affiche alors l’alerte
  # d’ouverture à la place de la liste.
  #
  # **Où** : page publique « Registre public », panneau latéral.
  def wallet_selected
    render Molecules::PublicRegistry::OriginFilterComponent.new(url: '#', placement: :sidebar, origins: ['portefeuille-europeen'])
  end

  # @label 4. Les deux choisis
  #
  # **Où** : page publique « Registre public », panneau latéral.
  def both_selected
    render Molecules::PublicRegistry::OriginFilterComponent.new(url: '#', placement: :sidebar, origins: %w[datapass portefeuille-europeen])
  end

  # @label 5. Emplacement mobile (visible sous 992 px)
  #
  # Affiché seulement sous 992 px de large (`fr-hidden-lg`), comme sur la page : le cadre
  # d’aperçu de Lookbook est plus large, l’aperçu paraît donc vide. Pour le voir, rétrécir le cadre
  # sous 992 px avec sa poignée de redimensionnement, ou ouvrir l’adresse de l’aperçu seul
  # (`/lookbook/preview/molecules/public_registry/origin_filter/mobile`) dans une fenêtre étroite.
  # Navigation au clavier : Tab passe d’un tag à l’autre, Entrée ou Espace envoie le formulaire.
  #
  # **Où** : page publique « Registre public », au-dessus de la liste, sous la recherche.
  def mobile
    render Molecules::PublicRegistry::OriginFilterComponent.new(url: '#', placement: :mobile, origins: ['datapass'])
  end
end
