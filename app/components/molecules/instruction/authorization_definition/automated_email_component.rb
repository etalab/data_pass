class Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent < ApplicationComponent
  SCOPE = 'instruction.authorization_definition_emails'.freeze

  delegate :reopening_badge, to: :decorated_request

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

  def title(rendered)
    available?(rendered) ? rendered.subject : scoped_t('unavailable_title')
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

  def error?(rendered)
    rendered.error.present?
  end

  def unavailable_message(rendered)
    return scoped_t('preview_error', message: rendered.error) if error?(rendered)

    scoped_t('preview_unavailable')
  end

  def card_data
    return {} unless reopening?

    { controller: 'toggle-class', toggle_class_class_value: 'fr-hidden' }
  end

  def variant_class(index)
    'fr-hidden' if reopening? && index == 1
  end

  def variant_data
    return {} unless reopening?

    { toggle_class_target: 'toggle' }
  end

  def toggle_input_id
    "reopening-toggle-#{@standard_email.mailer.parameterize}-#{@standard_email.action}"
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
    AuthorizationDefinition::AutomatedEmails.resulting_state(@event)
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
