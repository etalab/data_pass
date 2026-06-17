class DeliverMessageMailToApplicant < DeliverMessageMail
  private

  def recipients
    [authorization_request.applicant]
  end

  def base_mailer_method
    'to_applicant'
  end
end
