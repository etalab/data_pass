class Molecules::Instruction::AuthorizationDefinition::CardComponentPreview < ApplicationPreview
  def default
    definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::CardComponent.new(
      authorization_definition: definition,
      validated_count: 1373,
      submitted_count: 6
    )
  end
end
