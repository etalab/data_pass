class IncrementAuthorizationRequestUnreadCounter < ApplicationInteractor
  def call
    authorization_request.public_send(redis_counter_for_entity).increment
  end

  private

  def authorization_request
    context.authorization_request
  end

  def redis_counter_for_entity
    "redis_unread_messages_from_#{context.unread_counter_target}"
  end
end
