class AutomatedEmailPreview::Applicant < AutomatedEmailPreview
  def subject
    I18n.t(
      "authorization_request_mailer.#{event}.subject",
      authorization_request_id: SAMPLE_AUTHORIZATION_REQUEST_ID,
    )
  end

  private

  def body_template
    if template_exists?(kind_body_template)
      kind_body_template
    else
      "authorization_request_mailer/#{event}"
    end
  end

  def kind_body_template
    "authorization_request_mailer/#{definition.authorization_request_type}/#{event}"
  end
end
