class Molecules::Instruction::Form::ConfigBlockComponentPreview < ApplicationPreview
  def api_entreprise_marches_publics
    form = AuthorizationDefinition.find('api_entreprise').available_forms.find do |f|
      f.use_case == 'marches_publics'
    end
    render Molecules::Instruction::Form::ConfigBlockComponent.new(form:)
  end

  def api_entreprise_socle_de_base
    form = AuthorizationDefinition.find('api_entreprise').available_forms.find do |f|
      f.uid == 'api-entreprise-socle-de-base'
    end
    render Molecules::Instruction::Form::ConfigBlockComponent.new(form:)
  end
end
