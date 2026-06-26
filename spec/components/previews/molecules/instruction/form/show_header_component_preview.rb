class Molecules::Instruction::Form::ShowHeaderComponentPreview < ApplicationPreview
  def default
    authorization_definition = AuthorizationDefinition.find('api_entreprise')
    form = authorization_definition.available_forms.find do |f|
      f.use_case == 'marches_publics'
    end
    render Molecules::Instruction::Form::ShowHeaderComponent.new(
      authorization_definition:,
      form:,
      validated_count: 12,
      submitted_count: 3
    )
  end
end
