class EntityEligibility::Rules::HubEECertDC < EntityEligibility::Rules::Base
  def verdict
    return eligible(:commune) if commune?

    ineligible(:not_a_commune)
  end

  private

  def commune?
    organization.legal_category == :commune
  end
end
