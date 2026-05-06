class Molecules::Instruction::UserRights::ReadonlyRightsListComponent < ApplicationComponent
  def initialize(rights:)
    @rights = rights
  end

  def render?
    rights.any?
  end

  private

  attr_reader :rights
end
