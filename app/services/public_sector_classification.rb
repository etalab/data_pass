class PublicSectorClassification
  CLOSED_ADMINISTRATIVE_STATE = 'C'.freeze
  PUBLIC_REASONS = %i[public_legal_category whitelisted_siren].freeze

  def initialize(organization, lists: PublicSectorLists.instance)
    @unite_legale = organization.insee_payload.dig('etablissement', 'uniteLegale') || {}
    @siren = organization.siret.to_s.first(9)
    @lists = lists
  end

  def known?
    legal_category.present?
  end

  def public?
    PUBLIC_REASONS.include?(reason)
  end

  def private?
    known? && !public?
  end

  def reason
    return :unknown_legal_category unless known?
    return :blacklisted_siren if @lists.blacklisted_sirens.include?(@siren)
    return :closed_unit if closed?
    return :whitelisted_siren if @lists.whitelisted_sirens.include?(@siren)

    @lists.legal_categories.include?(legal_category) ? :public_legal_category : :private_legal_category
  end

  private

  def legal_category
    @unite_legale['categorieJuridiqueUniteLegale'].to_s
  end

  def closed?
    @unite_legale['etatAdministratifUniteLegale'] == CLOSED_ADMINISTRATIVE_STATE
  end
end
