class TriggerAuthorizationRequestEvent < ApplicationInteractor
  def call
    return if trigger_or_event_valid

    context.fail!(error: :trigger_event_failed)
  end

  private

  def trigger_or_event_valid
    if context.bypass_state_machine_event
      manually_affect_state
    else
      trigger_event
    end
  end

  def manually_affect_state
    if context.authorization_request.public_send("can_#{context.state_machine_event}?")
      context.authorization_request.state = context.state_machine_new_state
      true
    else
      false
    end
  end

  def trigger_event
    context.authorization_request.public_send(context.state_machine_event)
  end
end
