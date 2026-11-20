# @label Identité de l’organisation au registre wallet
#
# L’identité copiée dans la demande depuis les données INSEE de l’organisation, en lecture seule : nom, forme juridique et
# NAF, badge du demandeur, SIRET, code pays, secteur
# public d’après la catégorie juridique, adresse d’établissement.
#
# **Où** : registre wallet, étape « L’organisation », puis récapitulatif et instruction.
class Molecules::WalletRegistry::OrganizationIdentityComponentPreview < ApplicationPreview
  # @label 1. Collectivité (Ville de Clamart), agent connecté
  def municipality
    render Molecules::WalletRegistry::OrganizationIdentityComponent.new(authorization_request: draft_for('21920023500014'))
  end

  # @label 2. Entreprise (MGDIS), dirigeant certifié par ProConnect
  def company_certified_executive
    render Molecules::WalletRegistry::OrganizationIdentityComponent.new(authorization_request: draft_for('32816124500027'), executive_certified: true)
  end

  # @label 3. Entreprise (MGDIS), certification de dirigeant expirée ou abandonnée
  def company_executive_verification_required
    render Molecules::WalletRegistry::OrganizationIdentityComponent.new(authorization_request: draft_for('32816124500027'), executive_certified: false)
  end

  # @label 4. Entreprise (MGDIS), hors du parcours (récapitulatif, instruction) : sans badge
  def company
    render Molecules::WalletRegistry::OrganizationIdentityComponent.new(authorization_request: draft_for('32816124500027'))
  end

  private

  def draft_for(siret)
    AuthorizationRequest::RegistreWallet.new(organization: Organization.find_by!(legal_entity_id: siret), form_uid: 'registre-wallet').tap(&:copy_identity_from_sources)
  end
end
