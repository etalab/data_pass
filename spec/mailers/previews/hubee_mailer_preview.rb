class HubEEMailerPreview < ActionMailer::Preview
  def administrateur_metier_cert_dc
    HubEEMailer.with(authorization_request:).administrateur_metier(:cert_dc)
  end

  def administrateur_metier_dila
    HubEEMailer.with(authorization_request:).administrateur_metier(:dila)
  end

  def formulaire_qf_validation
    HubEEMailer.with(
      authorization_request: formulaire_qf_authorization_request,
      recipients: ['support@yopmail.com']
    ).formulaire_qf_validation
  end

  private

  def formulaire_qf_authorization_request
    AuthorizationRequest::FormulaireQF.where(state: 'validated').first ||
      AuthorizationRequest::APIParticulier.where(state: 'validated').first.tap { |request| request.modalities = %w[params formulaire_qf] }
  end

  def authorization_request
    AuthorizationRequest::HubEECertDC.first
  end
end
