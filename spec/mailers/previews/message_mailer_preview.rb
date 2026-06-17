class MessageMailerPreview < ActionMailer::Preview
  def to_applicant
    MessageMailer.with(message:).to_applicant
  end

  def to_instructors
    MessageMailer.with(message:, user: instructor).to_instructors
  end

  private

  def message
    Message.first
  end

  def instructor
    message.authorization_request.definition.instructors_and_managers.first
  end
end
