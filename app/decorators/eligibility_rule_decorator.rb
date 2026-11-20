class EligibilityRuleDecorator < ApplicationDecorator
  delegate_all

  decorates_association :options, with: EligibilityOptionDecorator

  def request_access_path(option = nil)
    h.new_authorization_request_path(
      **option_request_access_params(option),
      definition_id: definition_id,
      eligibility_confirmed: true,
      use_case: option&.use_case
    )
  end

  def request_access_label
    object.request_access_label.presence || t('eligibility.cta.request_access')
  end

  def title
    t("eligibility.titles.#{definition_id}") if I18n.exists?("eligibility.titles.#{definition_id}")
  end

  def lead
    t("eligibility.leads.#{definition_id}") if I18n.exists?("eligibility.leads.#{definition_id}")
  end

  private

  def option_request_access_params(option)
    return {} if option.nil?

    option.request_access_params.to_h.symbolize_keys
  end
end
