class EligibilityRuleDecorator < ApplicationDecorator
  delegate_all

  decorates_association :options, with: EligibilityOptionDecorator

  def request_access_path
    h.new_authorization_request_path(
      definition_id: definition_id,
      eligibility_confirmed: true
    )
  end
end
