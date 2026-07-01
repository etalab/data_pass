class Molecules::Instruction::EntityEligibilityAutoInstructionComponent < ApplicationComponent
  MODIFIERS = {
    validated: 'eligibility-notice--success',
    refused: 'fr-notice--alert',
  }.freeze

  def initialize(status:)
    @status = status
  end

  private

  def classes
    ['fr-notice', 'fr-notice--no-icon', 'fr-mb-3w', MODIFIERS.fetch(@status)]
  end

  def title
    t(".#{@status}.title")
  end

  def description
    t(".#{@status}.description")
  end
end
