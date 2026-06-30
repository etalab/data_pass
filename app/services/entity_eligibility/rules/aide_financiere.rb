class EntityEligibility::Rules::AideFinanciere < EntityEligibility::Rules::Base
  def verdict
    case organization.entity_type
    when :administration then eligible(:administration)
    when :gray_zone      then likely_eligible(:public_commercial)
    else                      ineligible(:not_administration)
    end
  end
end
