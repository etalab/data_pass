class AuthorizationRequest::RegistreWallet < AuthorizationRequest
  include AuthorizationExtensions::WalletOrganization
  include AuthorizationExtensions::WalletService
  include AuthorizationExtensions::WalletIntendedUses
  include AuthorizationExtensions::WalletContacts

  add_checkbox :wallet_registration_policy_accepted
  add_checkbox :wallet_information_certified

  def name
    wallet_service_name.presence || super
  end

  def required_for_step?(step)
    super && step.to_s == current_build_step
  end

  def skip_data_protection_officer_informed_check_box?
    true
  end
end
