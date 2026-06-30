class Molecules::Instruction::EntityEligibilityVerdictComponent < ApplicationComponent
  STATUS_MODIFIERS = {
    eligible: 'success',
    likely_eligible: 'info',
    likely_ineligible: 'warning',
    ineligible: 'error',
    unknown: nil,
  }.freeze

  def initialize(verdict:)
    @verdict = verdict
  end

  def call
    content_tag(:p, label, class: classes)
  end

  private

  def classes
    modifier = STATUS_MODIFIERS.fetch(@verdict.status)

    ['fr-badge', 'fr-badge--sm', ("fr-badge--#{modifier}" if modifier)].compact
  end

  def label
    t(".#{@verdict.status}")
  end
end
