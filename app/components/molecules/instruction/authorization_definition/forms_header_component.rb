class Molecules::Instruction::AuthorizationDefinition::FormsHeaderComponent < ApplicationComponent
  def initialize(authorization_definition:)
    @authorization_definition = authorization_definition
  end

  private

  attr_reader :authorization_definition

  def title
    I18n.t('instruction.authorization_definitions.forms_header_component.title')
  end

  def back_link
    {
      path: helpers.instruction_authorization_definition_path(authorization_definition),
      text: authorization_definition.name_with_stage
    }
  end
end
