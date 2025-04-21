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
      form_uid: lookup_form_id_from_previous_stages,
    )
  end

  def lookup_form_id_from_previous_stages
    authorization.request.definition.stage.previous_stages.find { |stage|
      stage[:definition].authorization_request_class.to_s == authorization.authorization_request_class
    }[:form].uid
  end

  def authorization
    context.authorization
  end

  def authorization_definition
    authorization.definition
  end
end
