class EntityEligibility::Rules::APIParticulier::Ccas < EntityEligibility::Rules::Base
  def verdict
    return ineligible(:categorie_juridique) unless organization.ccas_or_cias?

    likely_eligible(:categorie_juridique)
  end
end
