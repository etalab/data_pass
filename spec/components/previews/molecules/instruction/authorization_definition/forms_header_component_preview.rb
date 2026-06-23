class Molecules::Instruction::AuthorizationDefinition::FormsHeaderComponentPreview < ApplicationPreview
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::FormsHeaderComponent.new(
      authorization_definition:
    )
  end
end
