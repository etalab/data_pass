class EligibilityOptionDecorator < ApplicationDecorator
  delegate_all

  ALERT_CLASSES = {
    'yes' => 'fr-callout--green-emeraude',
    'no' => 'fr-callout--pink-macaron',
    'maybe' => 'fr-callout--yellow-tournesol'
  }.freeze

  CTA_BASE_OPTIONS = { class: 'fr-btn fr-btn--secondary' }.freeze

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
    h.sanitize(body, tags: %w[b i strong em p a br], attributes: %w[href target rel])
  end

  def label
    custom_label || t("eligibility.user_types.#{type}")
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

  def cta_opens_in_new_tab?
    ActiveModel::Type::Boolean.new.cast(cta['new_tab']) == true
  end

  def cta_html_options
    return CTA_BASE_OPTIONS unless cta_opens_in_new_tab?

    CTA_BASE_OPTIONS.merge(target: '_blank', rel: 'noopener noreferrer')
  end
end
