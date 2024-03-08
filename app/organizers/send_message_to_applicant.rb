class SendMessageToApplicant < ApplicationOrganizer
  before do
    context.message_from = context.user

    context.event_name = :instructor_message
    context.event_entity = :message

    context.mailer_method = :to_applicant

    context.unread_counter_target = :applicant
  end

  organize CreateMessageModel,
    CreateAuthorizationRequestEventModel,
    DeliverMessageMail,
    IncrementAuthorizationRequestUnreadCounter
end
