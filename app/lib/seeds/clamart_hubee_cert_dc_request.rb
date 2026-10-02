class Seeds::ClamartHubEECertDCRequest
  def initialize(context)
    @requests = context.requests
    @accounts = context.accounts
  end

  def perform
    @requests.create_validated_authorization_request(:portail_hubee_demarche_certdc, attributes: { description: nil, applicant: @accounts.dem_historique })
  end
end
