class Molecules::Instruction::Form::CardComponentPreview < ApplicationPreview
  def default
    authorization_request_form = AuthorizationDefinition.find('api_entreprise').available_forms.find do |form|
      form.use_case == 'marches_publics'
    end
    render Molecules::Instruction::Form::CardComponent.new(
      authorization_request_form:,
      validated_count: 12,
      submitted_count: 3
    )
  end

  def default_form
    authorization_request_form = AuthorizationDefinition.find('api_entreprise').default_form
    render Molecules::Instruction::AuthorizationDefinition::FormCardComponent.new(
      authorization_request_form:,
      validated_count: 5,
      submitted_count: 1
    )
  end
end
