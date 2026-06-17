class DeliverMessageMail < ApplicationInteractor
  def call
    recipients.each do |user|
      MessageMailer.with(message:, user:).public_send(mailer_method).deliver_later
    end
  end

  private

  def mailer_method
    if authorization_request.reopening?
      "reopening_#{base_mailer_method}"
    else
      base_mailer_method
    end
  end

  def message
    context.message
  end

  def authorization_request
    context.authorization_request
  end
end
