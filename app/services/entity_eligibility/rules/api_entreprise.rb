class EntityEligibility::Rules::APIEntreprise < EntityEligibility::Rules::Base
  MENUISERIE_NAF_CODES = %w[
    16.23Z
    43.32A
    43.32B
  ].freeze

  def verdict
    return ineligible(:menuiserie) if menuiserie?

    unknown
  end

  private

  def menuiserie?
    MENUISERIE_NAF_CODES.include?(organization.activite_principale)
  end
end
