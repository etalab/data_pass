class Molecules::Instruction::EntityEligibilityVerdictComponentPreview < ViewComponent::Preview
  def eligible
    render_verdict(:eligible)
  end

  def likely_eligible
    render_verdict(:likely_eligible)
  end

  def likely_ineligible
    render_verdict(:likely_ineligible)
  end

  def ineligible
    render_verdict(:ineligible)
  end

  def unknown
    render_verdict(:unknown)
  end

  private

  def render_verdict(status)
    render Molecules::Instruction::EntityEligibilityVerdictComponent.new(
      verdict: EntityEligibility::Verdict.new(status:),
    )
  end
end
