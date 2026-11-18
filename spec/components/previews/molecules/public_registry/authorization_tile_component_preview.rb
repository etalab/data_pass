# @label Tuile d’une habilitation (registre public)
#
# Tuile horizontale du DSFR (`DsfrComponent::TileComponent`) qui présente une habilitation active
# dans la liste du registre public : badge de statut « Active », badge d’origine, dénomination en
# titre (lien vers la fiche), puis sur une ligne, sans libellé visible, l’API ou le service, le
# fournisseur, la date de validation et le numéro d’habilitation.
#
# **Où** : page publique « Registre public », dans la liste des résultats
# (`Organisms::PublicRegistry::ResultsListComponent`), une tuile par habilitation (DPP-223, RG3).
#
# Les libellés « API ou service » et « Fournisseur » sont en `fr-sr-only` : seuls les lecteurs
# d’écran les lisent. L’intitulé du lien ajoute l’API ou le service en `fr-sr-only`, pour que deux
# tuiles de la même organisation gardent des liens distincts. Les valeurs de l’habilitation
# arrivent dans un `Molecules::PublicRegistry::AuthorizationEntry` (valeurs simples, pas de
# modèle) : la page y passe par exemple `authorization.formatted_id` en `number`.
class Molecules::PublicRegistry::AuthorizationTileComponentPreview < ApplicationPreview
  # @label 1. Nominal
  #
  # Habilitation API Particulier de la Ville de Clamart, fournie par la DINUM.
  #
  # **Où** : page publique « Registre public », liste des résultats.
  def nominal
    render Molecules::PublicRegistry::AuthorizationTileComponent.new(url: '#', entry: clamart_entry, origin: 'datapass')
  end

  # @label 2. Même organisation sur plusieurs tuiles
  #
  # Deux habilitations de la Ville de Clamart dans la liste. Les titres visibles sont identiques ;
  # les liens restent distincts pour les lecteurs d’écran grâce à l’API ou au service ajouté en
  # `fr-sr-only`.
  #
  # **Où** : page publique « Registre public », liste des résultats.
  def same_organization
    render Organisms::PublicRegistry::ResultsListComponent.new do |list|
      list.with_tile(url: '#', entry: clamart_entry, origin: 'datapass')
      list.with_tile(url: '#', entry: clamart_entry(service: 'HubEECertDC', number: 'H44121'), origin: 'datapass')
    end
  end

  # @label 3. Nom long
  #
  # Dénomination longue, qui passe sur plusieurs lignes.
  #
  # **Où** : page publique « Registre public », liste des résultats.
  def long_denomination
    render Molecules::PublicRegistry::AuthorizationTileComponent.new(url: '#', entry: clamart_entry(denomination: 'Secrétariat d’État chargé de l’Éducation prioritaire auprès du ministre de l’Éducation nationale', provider: 'DGFIP', service: 'APIImpotParticulier'), origin: 'datapass')
  end

  # @label 4. Nom de service long sans espace
  #
  # Nom technique long, sans espace : il se coupe à la ligne (`overflow-wrap: anywhere`, classe
  # `r-code`) au lieu de faire défiler la page à 375 px.
  #
  # **Où** : page publique « Registre public », liste des résultats.
  def long_service
    render Molecules::PublicRegistry::AuthorizationTileComponent.new(url: '#', entry: clamart_entry(service: 'APIGFEEchangeEditeursRestauration'), origin: 'datapass')
  end

  # @label 5. Dénomination vide
  #
  # Le titre affiche « Non renseigné » et mène quand même à la fiche (DPP-223, CA5).
  #
  # **Où** : page publique « Registre public », liste des résultats.
  def blank_denomination
    render Molecules::PublicRegistry::AuthorizationTileComponent.new(url: '#', entry: clamart_entry(denomination: nil), origin: 'datapass')
  end

  # @label 6. Habilitation du bac à sable
  #
  # Une habilitation de bac à sable s’affiche comme les autres : seul le nom du service le dit.
  #
  # **Où** : page publique « Registre public », liste des résultats.
  def sandbox
    render Molecules::PublicRegistry::AuthorizationTileComponent.new(url: '#', entry: clamart_entry(service: 'APIImpotParticulierSandbox', provider: 'DGFIP', number: 'H44122'), origin: 'datapass')
  end

  # @label 7. Badge d’origine « Partie utilisatrice du portefeuille européen »
  #
  # Variante de couleur du badge d’origine (`purple-glycine`), prévue pour l’après-ouverture du
  # registre du portefeuille européen. La tuile propre aux parties utilisatrices vient avec
  # DPP-246 ; seul le badge est livré ici. À 375 px, il passe sous le badge de statut.
  #
  # **Où** : nulle part avant l’ouverture du registre du portefeuille européen.
  def european_wallet_origin
    render Molecules::PublicRegistry::AuthorizationTileComponent.new(url: '#', entry: clamart_entry, origin: 'portefeuille-europeen')
  end

  private

  def clamart_entry(**overrides)
    Molecules::PublicRegistry::AuthorizationEntry.new(
      number: 'H44120',
      denomination: 'Ville de Clamart',
      service: 'APIParticulier',
      provider: 'DINUM',
      validated_on: Date.new(2026, 7, 2),
      **overrides
    )
  end
end
