class Molecules::Instruction::AuthorizationDefinition::TitledHeaderComponent < ApplicationComponent
  include Molecules::Instruction::Breadcrumb

  def initialize(authorization_definition:, title:)
    @authorization_definition = authorization_definition
    @title = title
  end

  private

  attr_reader :authorization_definition, :title

  def breadcrumbs
    [
      formulaires_breadcrumb_item,
      authorization_definition_breadcrumb_item,
      { label: title }
    ]
  end
end
