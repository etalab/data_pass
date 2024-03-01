class DeliverMessageMail < ApplicationInteractor
  def call
    MessageMailer.with(message:).public_send(mailer_method).deliver_later
  end

  private

  def message
    context.message
  end

  def mailer_method
    context.mailer_method
  end
end
