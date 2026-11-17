class AuthorizationRequest::RegistreWallet < AuthorizationRequest
  include AuthorizationExtensions::WalletOrganization
  include AuthorizationExtensions::WalletService

  def name
    wallet_service_name.presence || super
  end
end
