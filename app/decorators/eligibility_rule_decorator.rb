class EligibilityRuleDecorator < ApplicationDecorator
  ALLOWED_REQUEST_ACCESS_PARAMS = %w[parcours].freeze

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

  def lead
    t("eligibility.leads.#{definition_id}") if I18n.exists?("eligibility.leads.#{definition_id}")
  end

  private

  def option_request_access_params(option)
    params = option&.request_access_params
    return {} unless params.is_a?(Hash)

    params.stringify_keys.slice(*ALLOWED_REQUEST_ACCESS_PARAMS).symbolize_keys
  end
end
