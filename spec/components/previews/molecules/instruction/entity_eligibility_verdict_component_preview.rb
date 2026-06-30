class Molecules::Instruction::EntityEligibilityVerdictComponentPreview < ViewComponent::Preview
  def eligible
    render_verdict(:eligible, :administration)
  end

  def likely_eligible
    render_verdict(:likely_eligible, :public_commercial)
  end

  def likely_ineligible
    render_verdict(:likely_ineligible, :not_a_commune)
  end

  def ineligible
    render_verdict(:ineligible, :not_administration)
  end

  def unknown
    render_verdict(:unknown, nil)
  end

  private

  def render_verdict(status, reason)
    render Molecules::Instruction::EntityEligibilityVerdictComponent.new(
      verdict: EntityEligibility::Verdict.new(status:, reason:),
    )
  end
end
