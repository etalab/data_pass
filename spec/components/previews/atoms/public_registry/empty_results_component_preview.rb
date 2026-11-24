# @label Message de liste vide (registre public)
#
# Texte simple affiché à la place des tuiles quand aucune entrée ne correspond. La page choisit le
# cas avec `reason:` (DPP-223, RG5).
#
# **Où** : page publique « Registre public », colonne principale, sous le compteur d’entrées.
class Atoms::PublicRegistry::EmptyResultsComponentPreview < ApplicationPreview
  # @label 1. Sans filtre actif
  #
  # **Où** : page publique « Registre public », recherche sans résultat.
  def no_match
    render Atoms::PublicRegistry::EmptyResultsComponent.new(reason: :no_match)
  end

  # @label 2. Avec un filtre actif
  #
  # **Où** : page publique « Registre public », recherche sans résultat avec un filtre « Origine ».
  def no_match_filtered
    render Atoms::PublicRegistry::EmptyResultsComponent.new(reason: :no_match_filtered)
  end

  # @label 3. Aucune partie utilisatrice enregistrée
  #
  # Après l’ouverture du registre du portefeuille européen, filtre « Partie utilisatrice du
  # portefeuille européen » sans enregistrement publié (DPP-266, RG6).
  #
  # **Où** : nulle part avant l’ouverture du registre du portefeuille européen.
  def no_wallet_entry
    render Atoms::PublicRegistry::EmptyResultsComponent.new(reason: :no_wallet_entry)
  end
end
