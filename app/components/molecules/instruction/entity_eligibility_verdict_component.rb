class Molecules::Instruction::EntityEligibilityVerdictComponent < ApplicationComponent
  STATUS_MODIFIERS = {
    eligible: 'success',
    likely_eligible: 'info',
    likely_ineligible: 'warning',
    ineligible: 'error',
  }.freeze

  def initialize(verdict:)
    @verdict = verdict
  end

  def render?
    STATUS_MODIFIERS.key?(@verdict.status)
  end

  private

  def classes
    ['fr-callout', "eligibility-callout--#{STATUS_MODIFIERS.fetch(@verdict.status)}"]
  end

  def label
    t(".#{@verdict.status}")
  end

  def explanation
    t(".reasons.#{@verdict.reason || :none}", default: nil)
  end
end
