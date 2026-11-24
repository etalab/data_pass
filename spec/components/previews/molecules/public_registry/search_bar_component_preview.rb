# @label Barre de recherche (registre public)
#
# Barre de recherche du DSFR (`fr-search-bar`) écrite dans le composant, pour pouvoir y ajouter un
# texte d’aide : formulaire GET avec `role="search"`, champ `q` dont le placeholder est
# « Rechercher », comme dans `SearchComponent` de la gem, bouton « Rechercher ». Le texte d’aide,
# qui liste ce qu’on peut chercher (DPP-223, RG2), s’affiche sous la barre, en petit et en gris,
# relié au champ par `aria-describedby` : en placeholder, il était coupé à 375 px. Quand un filtre
# « Origine » est choisi, un champ caché `origine` le garde.
#
# **Où** : page publique « Registre public », sous le chapô.
class Molecules::PublicRegistry::SearchBarComponentPreview < ApplicationPreview
  # @label 1. Vide
  #
  # **Où** : page publique « Registre public », à l’ouverture.
  def empty
    render Molecules::PublicRegistry::SearchBarComponent.new(url: '#')
  end

  # @label 2. Saisie, avec un filtre choisi
  #
  # La recherche « clamart » est gardée dans le champ ; le filtre « Habilitation DataPass » passe
  # en champ caché.
  #
  # **Où** : page publique « Registre public », après une recherche.
  def with_query
    render Molecules::PublicRegistry::SearchBarComponent.new(url: '#', query: 'clamart', origins: ['datapass'])
  end

  # @label 3. Aucun résultat
  #
  # La recherche reste dans le champ ; le message de liste vide s’affiche sous le compteur.
  #
  # **Où** : page publique « Registre public », recherche sans résultat.
  def no_result
    render Molecules::PublicRegistry::SearchBarComponent.new(url: '#', query: 'lorvain')
  end
end
