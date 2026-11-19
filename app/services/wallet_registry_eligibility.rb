class WalletRegistryEligibility
  def initialize(organization:, applicant:, dirigeant_verification: nil)
    @organization = organization
    @applicant = applicant
    @dirigeant_verification = dirigeant_verification
  end

  def capacity
    return :public_agent if public_organization?
    return :executive if certified_executive?

    :sector_pending if sector_unknown?
  end

  def violation
    :executive_certification_required if capacity.blank?
  end

  private

  attr_reader :organization, :applicant, :dirigeant_verification

  def public_organization?
    organization.present? && sector_classification.public?
  end

  def sector_unknown?
    organization.present? && !sector_classification.known?
  end

  def sector_classification
    @sector_classification ||= PublicSectorClassification.new(organization)
  end

  def certified_executive?
    dirigeant_verification.present? && dirigeant_verification.valid_for?(user: applicant, organization:)
  end
end
