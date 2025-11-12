class EligibilityOptionDecorator < ApplicationDecorator
  delegate_all

  ALERT_CLASSES = {
    'yes' => 'fr-callout--green-emeraude',
    'no' => 'fr-callout--pink-macaron',
    'maybe' => 'fr-callout--yellow-tournesol'
  }.freeze

  def id
    "#{type}-option"
  end

  def outcome_id
    "#{type}-outcome"
  end

  def alert_class
    ALERT_CLASSES[eligible]
  end

  def sanitized_body
    h.sanitize(body, tags: %w[b i strong em p a], attributes: %w[href])
  end

  def label
    t("eligibility.user_types.#{type}")
  end

  def shows_request_access_button?
    %w[yes maybe].include?(eligible)
  end

  def shows_custom_cta?
    cta.present? && cta['url'].present?
  end

  def cta_content
    cta['content']
  end

  def cta_url
    cta['url']
  end
end
