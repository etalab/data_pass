class Molecules::Instruction::AuthorizationDefinition::TitledHeaderComponentPreview < ApplicationPreview
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::TitledHeaderComponent.new(
      authorization_definition:,
      title: I18n.t('instruction.authorization_definitions.edit.title')
    )
  end

  def emails
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::TitledHeaderComponent.new(
      authorization_definition:,
      title: I18n.t('instruction.authorization_definition_emails.index.title')
    )
  end
end
