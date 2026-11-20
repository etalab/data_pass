# @label Organisation dans le registre (récapitulatif du registre wallet)
#
# Le bloc « L’organisation dans le registre » du récapitulatif : « Identification » (nom officiel, SIRET, code pays,
# secteur public, adresse, non-inscription dans un autre État), puis « Informations pour les usagers » sur deux
# colonnes. Libellé petit et gris, valeur en gras.
#
# **Où** : registre wallet, récapitulatif avant soumission, et consultation de la demande.
class Molecules::WalletRegistry::OrganizationSummaryComponentPreview < ApplicationPreview
  # @label 1. Collectivité (Ville de Clamart), étape remplie
  def municipality
    render Molecules::WalletRegistry::OrganizationSummaryComponent.new(authorization_request: filled_draft_for('21920023500014'))
  end

  # @label 2. Identité saisie par le demandeur (Sirene n’a pas répondu)
  def typed_identity
    draft = filled_draft_for('21920023500014')
    draft.identity_source = 'sirene_unavailable'
    draft.wallet_legal_name = 'COMMUNE DE CLAMART'
    draft.wallet_postal_address = '1 place Maurice Gunsbourg, 92140 Clamart'

    render Molecules::WalletRegistry::OrganizationSummaryComponent.new(authorization_request: draft)
  end

  private

  def filled_draft_for(siret)
    AuthorizationRequest::RegistreWallet.new(
      organization: Organization.find_by!(legal_entity_id: siret),
      form_uid: 'registre-wallet',
      wallet_privacy_policy_url: 'https://www.clamart.fr/confidentialite',
      wallet_website_url: 'https://www.clamart.fr',
      wallet_support_email: 'contact@clamart.fr',
      wallet_not_registered_elsewhere: true
    ).tap(&:copy_identity_from_sources)
  end
end
