class HubEEMailerPreview < ActionMailer::Preview
  def administrateur_metier_cert_dc
    HubEEMailer.with(authorization_request:).administrateur_metier(:cert_dc)
  end

  def administrateur_metier_dila
    HubEEMailer.with(authorization_request:).administrateur_metier(:dila)
  end

  private

  def authorization_request
    AuthorizationRequest::HubEECertDC.first
  end
end
