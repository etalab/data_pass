class TransitionAuthorizationRequestToStageOfAuthorization < ApplicationInteractor
  def call
    context.fail! unless context.authorization.reopenable?

    return if context.authorization_request.is_a? context.authorization.authorization_request_class.constantize

    transition_to_authorization_stage
  end

  private

  def transition_to_authorization_stage
    context.authorization_request.update!(
      type: context.authorization.authorization_request_class.to_s,
      form_uid: context.authorization.form_uid,
    )
  end
end
