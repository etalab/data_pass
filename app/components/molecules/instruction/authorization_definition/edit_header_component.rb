class Molecules::Instruction::AuthorizationDefinition::EditHeaderComponent < ApplicationComponent
  def initialize(authorization_definition:, title:)
    @authorization_definition = authorization_definition
    @title = title
  end

  private

  attr_reader :authorization_definition, :title

  def back_link
    {
      path: helpers.instruction_authorization_definition_path(authorization_definition),
      text: authorization_definition.name_with_stage
    }
  end
end
