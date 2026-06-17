class SendMessageToApplicant < ApplicationOrganizer
  before do
    context.message_from = context.user

    context.event_name = :instructor_message
    context.event_entity = :message

    context.unread_counter_target = :instructors
  end

  organize CreateMessageModel,
    CreateAuthorizationRequestEventModel,
    DeliverMessageMailToApplicant,
    IncrementAuthorizationRequestUnreadCounter
end
