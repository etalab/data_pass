class Molecules::Instruction::AuthorizationDefinition::ShowHeaderComponentPreview < ApplicationPreview
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::ShowHeaderComponent.new(
      authorization_definition:,
      validated_count: 1373,
      submitted_count: 6
    )
  end
end
