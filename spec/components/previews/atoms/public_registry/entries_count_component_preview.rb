# @label Compteur d’entrées (registre public)
#
# Paragraphe simple qui annonce le nombre d’entrées de la liste, en gras, suivi de « au registre »
# ou de la recherche entre guillemets. Il n’a pas de zone `aria-live` : la page se recharge à
# chaque recherche, et le nombre est lu dans le titre de la page, que la page pose avec
# `set_title!` (DPP-223, RG4).
#
# **Où** : page publique « Registre public », colonne principale, au-dessus des tuiles.
class Atoms::PublicRegistry::EntriesCountComponentPreview < ApplicationPreview
  # @label 1. Sans recherche
  #
  # **Où** : page publique « Registre public », à l’ouverture.
  def without_query
    render Atoms::PublicRegistry::EntriesCountComponent.new(count: 31_751)
  end

  # @label 2. Après une recherche
  #
  # **Où** : page publique « Registre public », après une recherche.
  def with_query
    render Atoms::PublicRegistry::EntriesCountComponent.new(count: 1, query: 'clamart')
  end

  # @label 3. Aucune entrée
  #
  # Le compteur reste affiché au-dessus du message de liste vide ou de l’alerte d’ouverture.
  #
  # **Où** : page publique « Registre public », recherche sans résultat.
  def no_entry
    render Atoms::PublicRegistry::EntriesCountComponent.new(count: 0, query: 'portefeuille')
  end
end
