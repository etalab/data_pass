class Molecules::Instruction::EntityEligibilityAutoInstructionComponentPreview < ViewComponent::Preview
  def validated
    render Molecules::Instruction::EntityEligibilityAutoInstructionComponent.new(status: :validated)
  end

  def refused
    render Molecules::Instruction::EntityEligibilityAutoInstructionComponent.new(status: :refused)
  end
end
