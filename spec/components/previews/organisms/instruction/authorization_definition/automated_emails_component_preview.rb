class Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponentPreview < ApplicationPreview
  def basic
    render Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent.new(
      authorization_definition: AuthorizationDefinition.find('annuaire_des_entreprises')
    )
  end

  def with_france_connect_and_embedded_fields
    render Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent.new(
      authorization_definition: AuthorizationDefinition.find('api_particulier')
    )
  end

  def with_gdpr_and_dgfip
    render Organisms::Instruction::AuthorizationDefinition::AutomatedEmailsComponent.new(
      authorization_definition: AuthorizationDefinition.find('api_ficoba')
    )
  end
end
