class CreateAuthorizationRequestEventModel < ApplicationInteractor
  def call
    context.authorization_request_event = AuthorizationRequestEvent.create!(
      name: event_name,
      user: context.user,
      entity:,
    )
  end

  def rollback
    context.authorization_request_event.destroy
  end

  private

  def event_name
    context.event_name ||
      context.state_machine_event
  end

  def entity
    if context.event_entity
      context.public_send(context.event_entity)
    else
      context.authorization_request
    end
  end
end
