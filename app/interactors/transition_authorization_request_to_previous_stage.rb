class TransitionAuthorizationRequestToPreviousStage < ApplicationInteractor
  def call
    return if context.authorization_request_class.blank?

    context.fail! unless context.authorization_request.can_reopen_to_class?(context.authorization_request_class)

    return if context.authorization_request.is_a? context.authorization_request_class

    transition_to_previous_stage
  end

  private

  def transition_to_previous_stage
    context.authorization_request.update!(
      type: context.authorization_request_class.to_s,
      form_uid: context.authorization_request.definition.previous_stage_form(context.authorization_request_class).id
    )
  end
end
