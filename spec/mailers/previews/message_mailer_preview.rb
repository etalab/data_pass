class MessageMailerPreview < ActionMailer::Preview
  def to_applicant
    MessageMailer.with(message:).to_applicant
  end

  def to_instructors
    MessageMailer.with(message:).to_instructors
  end

  private

  def message
    Message.first
  end
end
