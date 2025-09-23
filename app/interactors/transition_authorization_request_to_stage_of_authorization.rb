class TransitionAuthorizationRequestToStageOfAuthorization < ApplicationInteractor
  def call
    context.fail! unless context.authorization.reopenable?

    return if context.authorization_request.type == context.authorization.authorization_request_class

    transition_to_authorization_stage
  end

  private

  def transition_to_authorization_stage
    context.authorization_request.update!(
      type: context.authorization.authorization_request_class.to_s,
      form_uid: lookup_form_id_from_previous_stage,
    )
  end

  def lookup_form_id_from_previous_stage
    find_previous_stage_form_for_request(authorization.request).uid
  end

  def find_previous_stage_form_for_request(authorization_request)
    previous_stage = authorization_request.definition.stage.previous_stage

    raise(ActiveRecord::RecordNotFound, "No previous stage configured for #{authorization_request.type}") if previous_stage[:form].blank?

    previous_stage[:form]
  end

  def authorization = context.authorization
end
