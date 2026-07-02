class EntityEligibility::Rules::APIParticulier::StationnementResidentiel < EntityEligibility::Rules::Base
  def verdict
    return likely_eligible(:categorie_juridique) if organization.bloc_communal?

    ineligible(:categorie_juridique)
  end
end
