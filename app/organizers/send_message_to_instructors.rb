class SendMessageToInstructors < ApplicationOrganizer
  before do
    context.message_from = context.user

    context.event_name = :applicant_message
    context.event_entity = :message

    context.mailer_method = :to_instructors

    context.unread_counter_target = :instructors
  end

  organize CreateMessageModel,
    CreateAuthorizationRequestEventModel,
    DeliverMessageMail,
    IncrementAuthorizationRequestUnreadCounter
end
