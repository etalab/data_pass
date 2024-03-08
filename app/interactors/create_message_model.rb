class CreateMessageModel < ApplicationInteractor
  def call
    context.message = Message.create(message_params)

    return if context.message.persisted?

    context.fail!
  end

  private

  def message_params
    context.message_params.merge(
      from: context.message_from,
      authorization_request: context.authorization_request,
      sent_at: Time.zone.now,
    )
  end
end
