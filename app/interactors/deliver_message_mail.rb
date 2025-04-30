class DeliverMessageMail < ApplicationInteractor
  def call
    MessageMailer.with(message:).public_send(mailer_method).deliver_later
  end

  private

  def message
    context.message
  end

  def mailer_method
    if authorization_request.reopening? || authorization_request.is_reopening?
      "reopening_#{context.mailer_method}"
    else
      context.mailer_method
    end
  end

  def authorization_request
    context.authorization_request
  end
end
