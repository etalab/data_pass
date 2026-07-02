class EntityEligibility::Rules::APIParticulier::TarificationEaje < EntityEligibility::Rules::Base
  CRECHE_HALTE_GARDERIE_NAF = '88.91A'.freeze

  def verdict
    return eligible(:categorie_juridique) if organization.bloc_communal? || creche_ou_halte_garderie?
    return likely_eligible(:categorie_juridique) if organization.association?

    ineligible(:categorie_juridique)
  end

  private

  def creche_ou_halte_garderie?
    organization.activite_principale == CRECHE_HALTE_GARDERIE_NAF
  end
end
