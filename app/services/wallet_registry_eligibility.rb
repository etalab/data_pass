class WalletRegistryEligibility
  def initialize(organization:, applicant:)
    @organization = organization
    @applicant = applicant
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

  attr_reader :organization, :applicant

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
    applicant.present? && organization.present? && applicant.organizations_users.certified_dirigeant.exists?(organization:)
  end
end
