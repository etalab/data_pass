class CancelNextAuthorizationRequestStage < ApplicationOrganizer
  before do
    context.state_machine_event = :cancel_next_stage

    context.bypass_state_machine_event = true
    context.state_machine_new_state = :validated

    context.authorization = context.authorization_request.latest_authorization_of_stage('sandbox')
    context.production_stage_form = context.authorization_request.form
  end

  after do
    context.authorization_request.assign_attributes(attributes_for_cancel_next_stage)
    context.authorization_request.save(validate: false)

    reload_authorization_request!

    affect_valid_form_uid!
  end

  organize ExecuteAuthorizationRequestTransitionWithCallbacks,
    RestoreAuthorizationRequestToAuthorization

  def attributes_for_cancel_next_stage
    {
      terms_of_service_accepted: true,
      data_protection_officer_informed: true,
    }
  end

  def reload_authorization_request!
    context.authorization_request = AuthorizationRequest.find(context.authorization_request.id)
  end

  def affect_valid_form_uid!
    context.authorization_request.form_uid = extract_previous_form_uid
    context.authorization_request.save(validate: false)
  end

  def extract_previous_form_uid
    context.production_stage_form.stage.previous_form_uid
  end
end
