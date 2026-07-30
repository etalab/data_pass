class Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponentPreview < ApplicationPreview
  def with_reopening_toggle
    definition = AuthorizationDefinition.find('annuaire_des_entreprises')
    render Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent.new(
      authorization_definition: definition,
      event: 'approve',
      standard_email: email('AuthorizationRequestMailer', 'approve', { reopening: false }),
      reopening_email: email('AuthorizationRequestMailer', 'reopening_approve', { reopening: true })
    )
  end

  def with_condition
    definition = AuthorizationDefinition.find('api_particulier')
    render Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent.new(
      authorization_definition: definition,
      event: 'approve',
      standard_email: email('FranceConnectMailer', 'new_scopes', { with_france_connect: true })
    )
  end

  def with_error
    definition = AuthorizationDefinition.find('annuaire_des_entreprises')
    render Molecules::Instruction::AuthorizationDefinition::AutomatedEmailComponent.new(
      authorization_definition: definition,
      event: 'approve',
      standard_email: email('UnknownMailer', 'approve', { reopening: false })
    )
  end

  private

  def email(mailer, action, state)
    AuthorizationDefinition::AutomatedEmails::Email.new(mailer:, action:, state:)
  end
end
