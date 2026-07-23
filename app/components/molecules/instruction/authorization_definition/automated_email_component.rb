class Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent < ApplicationComponent
  SCOPE = 'instruction.authorization_definition_emails'.freeze

  def initialize(authorization_definition:, standard_email:, event:, reopening_email: nil, heading: 'h3')
    @authorization_definition = authorization_definition
    @standard_email = standard_email
    @event = event
    @reopening_email = reopening_email
    @heading = heading
  end

  def variants
    @variants ||= [render_email(@standard_email), (render_email(@reopening_email) if reopening?)].compact
  end

  def reopening?
    @reopening_email.present?
  end

  def available?(rendered)
    rendered.body.present?
  end

  def condition?
    condition_keys.any?
  end

  def condition
    condition_keys.map { |key| scoped_t("states.#{key}") }.join(' · ')
  end

  def status_label
    scoped_t('status_label')
  end

  def recipients_label
    scoped_t('recipients_label')
  end

  def reopening_toggle_label
    scoped_t('reopening_toggle')
  end

  def state_badge
    decorated_request.status_badge
  end

  def reopening_badge(index)
    decorated_request.reopening_badge(extra_css_class: reopening_badge_muted_class(index).to_s)
  end

  def reopening_badge_muted_class(index)
    'reopening-badge--muted' unless toggle_checked?(index)
  end

  def error?(rendered)
    rendered.error.present?
  end

  def unavailable_message(rendered)
    return scoped_t('preview_error', message: rendered.error) if error?(rendered)

    scoped_t('preview_unavailable')
  end

  def variant_class(index)
    'fr-hidden' if reopening? && index == 1
  end

  def variant_data(index)
    return {} unless reopening?

    { reopening_email_target: index.zero? ? 'standard' : 'reopening' }
  end

  def toggle_input_id(index)
    "reopening-toggle-#{@standard_email.mailer.parameterize}-#{@standard_email.action}-#{index}"
  end

  def toggle_checked?(index)
    index == 1
  end

  attr_reader :heading

  private

  attr_reader :authorization_definition

  def decorated_request
    @decorated_request ||= authorization_definition.authorization_request_class.new.tap { |request|
      request.state = resulting_state.to_s
      request.define_singleton_method(:reopening?) { true }
    }.decorate
  end

  def resulting_state
    AuthorizationRequest.state_after(@event)
  end

  def render_email(email)
    AutomatedEmailPreviewRenderer.new(authorization_definition, email).call
  end

  def condition_keys
    @standard_email.state.keys - [:reopening]
  end

  def scoped_t(key, **)
    I18n.t("#{SCOPE}.#{key}", **)
  end
end
