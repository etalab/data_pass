class EntityEligibility::Rules::APIParticulier::AidesFacultatives < EntityEligibility::Rules::Base
  REGIONALE_FORMS = %w[
    api-particulier-aides-facultatives-regionales
  ].freeze

  def verdict
    verdict_for_category(regionale? ? :region : :dept)
  end

  private

  def regionale?
    REGIONALE_FORMS.include?(authorization_request_form.uid)
  end

  def verdict_for_category(expected)
    return likely_eligible(:categorie_juridique) if organization.legal_category == expected

    ineligible(:categorie_juridique)
  end
end
