class SendMessageToInstructors < ApplicationOrganizer
  before do
    context.message_from = context.user

    context.event_name = :applicant_message
    context.event_entity = :message

    context.unread_counter_target = :applicant
  end

  organize CreateMessageModel,
    CreateAuthorizationRequestEventModel,
    DeliverMessageMailToInstructors,
    IncrementAuthorizationRequestUnreadCounter
end
