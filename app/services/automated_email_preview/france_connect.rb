class AutomatedEmailPreview::FranceConnect < AutomatedEmailPreview
  def subject
    "[DataPass] nouveaux scopes pour \"#{sample_authorization_request.organization.name} - #{SAMPLE_AUTHORIZATION_REQUEST_ID}\""
  end

  def recipient_emails
    ['support.partenaires@franceconnect.gouv.fr']
  end

  private

  def body_template
    'france_connect_mailer/new_scopes'
  end

  def assigns
    super.merge(france_connect_authorization_request: sample_authorization_request)
  end
end
