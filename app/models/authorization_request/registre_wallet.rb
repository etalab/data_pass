class AuthorizationRequest::RegistreWallet < AuthorizationRequest
  include AuthorizationExtensions::WalletOrganization
  include AuthorizationExtensions::WalletService
  include AuthorizationExtensions::WalletIntendedUses

  def name
    wallet_service_name.presence || super
  end
end
