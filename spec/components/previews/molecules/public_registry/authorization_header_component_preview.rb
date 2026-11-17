# @label En-tête de la fiche d’une habilitation (registre public)
#
# Badges de statut et d’origine dans un groupe de badges du DSFR (`ul.fr-badges-group`), puis la
# dénomination en titre de page (`h1`, à la taille `fr-h2`). Le statut est un
# `DsfrComponent::BadgeComponent` « Active » ; l’origine un `Atoms::ColorBadgeComponent`, qui rend
# les mêmes classes que le badge d’origine de la tuile.
#
# **Où** : page publique « Fiche d’une habilitation » du registre public, sous le fil d’Ariane
# (DPP-224, RG2). Le fil d’Ariane et le lien « Retour au registre » appartiennent à la page.
class Molecules::PublicRegistry::AuthorizationHeaderComponentPreview < ApplicationPreview
  # @label 1. Nominal
  #
  # **Où** : fiche d’une habilitation du registre public.
  def nominal
    render Molecules::PublicRegistry::AuthorizationHeaderComponent.new(denomination: 'Ville de Clamart')
  end

  # @label 2. Nom long
  #
  # **Où** : fiche d’une habilitation du registre public.
  def long_denomination
    render Molecules::PublicRegistry::AuthorizationHeaderComponent.new(
      denomination: 'Secrétariat d’État chargé de l’Éducation prioritaire auprès du ministre de l’Éducation nationale'
    )
  end

  # @label 3. Dénomination vide
  #
  # Le titre affiche « Non renseigné » (DPP-224, RG2).
  #
  # **Où** : fiche d’une habilitation du registre public.
  def blank_denomination
    render Molecules::PublicRegistry::AuthorizationHeaderComponent.new(denomination: nil)
  end

  # @label 4. Badge d’origine « Partie utilisatrice du portefeuille européen »
  #
  # Variante de couleur (`purple-glycine`) prévue pour l’après-ouverture du registre du
  # portefeuille européen. La fiche propre aux parties utilisatrices vient avec DPP-245.
  #
  # **Où** : nulle part avant l’ouverture du registre du portefeuille européen.
  def european_wallet_origin
    render Molecules::PublicRegistry::AuthorizationHeaderComponent.new(denomination: 'Ville de Clamart', origin: 'portefeuille-europeen')
  end
end
