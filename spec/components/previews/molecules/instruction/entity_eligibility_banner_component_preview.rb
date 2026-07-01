class Molecules::Instruction::EntityEligibilityBannerComponentPreview < ViewComponent::Preview
  def validated
    render_banner(:validated)
  end

  def refused
    render_banner(:refused)
  end

  def likely_eligible
    render_banner(:likely_eligible)
  end

  def likely_ineligible
    render_banner(:likely_ineligible)
  end

  private

  def render_banner(status)
    render Molecules::Instruction::EntityEligibilityBannerComponent.new(status:)
  end
end
