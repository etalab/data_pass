class DeliverMessageMailToInstructors < DeliverMessageMail
  private

  def recipients
    Instruction::NotificationRecipients.messages(authorization_request)
  end

  def base_mailer_method
    'to_instructors'
  end
end
