class EntityEligibility::Rules::APIParticulier::CantinesCollegesLyceesTarification < EntityEligibility::Rules::Base
  LYCEE_FORMS = %w[
    api-particulier-tarification-cantines-lycees
    api-particulier-mgdis-tarification-cantines-lycees
  ].freeze

  COLLEGE_FORMS = %w[
    api-particulier-tarification-cantines-colleges
    api-particulier-capdemat-capdemat-evolution
  ].freeze

  def verdict
    return verdict_for_category(:region) if LYCEE_FORMS.include?(form_uid)
    return verdict_for_category(:dept) if COLLEGE_FORMS.include?(form_uid)

    unknown
  end

  private

  def form_uid
    authorization_request_form.uid
  end

  def verdict_for_category(expected)
    return likely_eligible(:categorie_juridique) if organization.legal_category == expected

    ineligible(:categorie_juridique)
  end
end
