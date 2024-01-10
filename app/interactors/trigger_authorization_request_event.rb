class TriggerAuthorizationRequestEvent < ApplicationInteractor
  def call
    return if trigger_event

    context.fail!(error: :trigger_event_failed)
  end

  private

  def trigger_event
    context.authorization_request.public_send(context.state_machine_event)
  end
end
