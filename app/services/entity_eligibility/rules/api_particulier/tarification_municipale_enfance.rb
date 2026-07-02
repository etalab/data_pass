class EntityEligibility::Rules::APIParticulier::TarificationMunicipaleEnfance < EntityEligibility::Rules::Base
  def verdict
    return likely_eligible(:categorie_juridique) if organization.bloc_communal? || organization.association?

    unknown
  end
end
