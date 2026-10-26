class CreateAuthorizationRequestEventModel < ApplicationInteractor
  def call
    context.authorization_request_event = AuthorizationRequestEvent.create!(
      name: event_name,
      user: context.user,
      entity:,
      authorization_request:,
      api_application_name: context.api_application_name,
      notifications_disabled: context.notification_policy&.suppressed_any? || false,
    )
  end

  def rollback
    context.authorization_request_event.destroy
  end

  private

  def authorization_request
    entity.authorization_request
  rescue StandardError
    context.authorization_request || entity
  end

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
