class Instruction::FormManagementController < InstructionController
  private

  def layout_name
    'wide_container'
  end

  def build_preview_request(form)
    @authorization_definition.authorization_request_class.new(form_uid: form.uid).tap { |ar|
      ar.assign_attributes(form.initialize_with)
    }.decorate
  end

  def preview_organization
    Struct.new(:name, :siret, :active_authorization_requests).new("NOM DE L'ORGANISATION", nil, AuthorizationRequest.none)
  end
end
