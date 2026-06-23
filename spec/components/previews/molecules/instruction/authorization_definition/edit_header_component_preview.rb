class Molecules::Instruction::AuthorizationDefinition::EditHeaderComponentPreview < ApplicationPreview
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::EditHeaderComponent.new(
      authorization_definition:,
      title: I18n.t('instruction.authorization_definitions.edit.title')
    )
  end
end
