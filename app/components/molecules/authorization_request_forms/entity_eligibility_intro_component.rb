class Molecules::AuthorizationRequestForms::EntityEligibilityIntroComponent < ApplicationComponent
  HINT_VARIANTS = {
    eligible: { variant: 'auto', icon: 'fr-icon-success-line' },
    likely_eligible: { variant: 'info', icon: 'fr-icon-thumb-up-line' },
    likely_ineligible: { variant: 'warning', icon: 'fr-icon-alert-line' },
  }.freeze

  def initialize(verdict:, authorization_request_form:)
    @verdict = verdict
    @form = authorization_request_form
  end

  def render?
    !@verdict.unknown?
  end

  delegate :ineligible?, to: :@verdict

  private

  attr_reader :verdict

  def hint
    HINT_VARIANTS.fetch(verdict.status)
  end

  def title
    translate_eligibility("#{verdict.status}.title")
  end

  def body
    translate_eligibility("#{verdict.status}.body_html", reason_clause:)
  end

  def reason_clause
    return '' if verdict.reason.blank?

    fragment = translate_eligibility("reasons.#{verdict.reason}")

    fragment.present? ? "#{fragment}, " : ''
  end

  def support_email
    @form.authorization_definition.support_email
  end

  def definition_name
    @form.authorization_definition.name
  end

  def rule_key
    @form.authorization_request_class.name.demodulize.underscore
  end

  def translate_eligibility(path, **)
    t(
      "entity_eligibility.#{rule_key}.#{path}",
      default: [:"entity_eligibility.base.#{path}", nil],
      definition: definition_name,
      **,
    )
  end
end
