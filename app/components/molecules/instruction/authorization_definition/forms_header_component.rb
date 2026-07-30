class Molecules::Instruction::AuthorizationDefinition::FormsHeaderComponent < ApplicationComponent
  include Molecules::Instruction::Breadcrumb

  def initialize(authorization_definition:)
    @authorization_definition = authorization_definition
  end

  private

  attr_reader :authorization_definition

  def title
    I18n.t('instruction.authorization_definitions.forms_header_component.title')
  end

  def breadcrumbs
    [
      formulaires_breadcrumb_item,
      authorization_definition_breadcrumb_item,
      { label: title }
    ]
  end
end
