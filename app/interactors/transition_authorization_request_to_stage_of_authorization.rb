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
    authorization_request.definition.stage.previous_stage[:form] || raise(ActiveRecord::RecordNotFound, "Couldn't find form within previous stages with id '#{previous_stage[:form_id]}'")
  end

  def authorization = context.authorization
end
