class DeliverMessageMail < ApplicationInteractor
  def call
    recipients.each do |user|
      MessageMailer.with(message:, user:).public_send(mailer_method).deliver_later
    end
  end

  private

  def recipients
    if mailer_method.start_with?('to_applicant', 'reopening_to_applicant')
      [authorization_request.applicant]
    else
      Instruction::NotificationRecipients.messages(authorization_request)
    end
  end

  def message
    context.message
  end

  def mailer_method
    if authorization_request.reopening?
      "reopening_#{context.mailer_method}"
    else
      context.mailer_method
    end
  end

  def authorization_request
    context.authorization_request
  end
end
