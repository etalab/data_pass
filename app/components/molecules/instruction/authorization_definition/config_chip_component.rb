class Molecules::Instruction::AuthorizationDefinition::ConfigChipComponent < ApplicationComponent
  renders_one :value

  def initialize(label:)
    @label = label
  end

  private

  attr_reader :label
end
