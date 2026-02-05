class CreateLinkedFranceConnectAuthorizationEvent < ApplicationInteractor
  def call
    return unless context.linked_france_connect_authorization

    context.linked_france_connect_authorization_event = auto_generate_event
  end

  def rollback
    context.linked_france_connect_authorization_event&.destroy
  end

  private

  def auto_generate_event
    AuthorizationRequestEvent.create!(
      name: 'auto_generate',
      user: context.user,
      entity: context.linked_france_connect_authorization,
      authorization_request: context.authorization_request
    )
  end
end
