class Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponentPreview < ApplicationPreview
  def api_entreprise
    definition = AuthorizationDefinition.find('api_entreprise')
    render Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent.new(
      authorization_definition: definition
    )
  end

  def api_impot_particulier
    definition = AuthorizationDefinition.find('api_impot_particulier')
    render Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent.new(
      authorization_definition: definition
    )
  end

  def hubee_dila
    definition = AuthorizationDefinition.find('hubee_dila')
    render Molecules::Instruction::AuthorizationDefinition::ConfigBlockComponent.new(
      authorization_definition: definition
    )
  end
end
