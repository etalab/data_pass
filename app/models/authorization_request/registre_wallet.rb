class AuthorizationRequest::RegistreWallet < AuthorizationRequest
  include AuthorizationExtensions::WalletOrganization
  include AuthorizationExtensions::WalletService
  include AuthorizationExtensions::WalletIntendedUses
  include AuthorizationExtensions::WalletContacts

  add_checkbox :wallet_registration_policy_accepted
  add_checkbox :wallet_information_certified

  validate :wallet_public_sector_known, on: :submit

  def name
    wallet_service_name.presence || super
  end

  def required_for_step?(step)
    super && step.to_s == current_build_step
  end

  def skip_data_protection_officer_informed_check_box?
    true
  end

  def executive_reconnection_required_to_submit?
    !identity_public_sector.nil? && !wallet_public_sector?
  end

  def wallet_incomplete_steps
    errors.attribute_names.excluding(:base).map { |attribute| wallet_step_of(attribute) }.uniq.sort_by { |step| steps_names.index(step) }
  end

  private

  def wallet_public_sector_known
    errors.add(:identity_public_sector, :wallet_public_sector_unknown) if identity_public_sector.nil? && !identity_pending?
  end

  def wallet_step_of(attribute)
    case attribute.to_s
    when /\Awallet_service_/ then 'wallet_service'
    when /\Awallet_intended_use/ then 'wallet_intended_uses'
    when /\A(#{AuthorizationExtensions::WalletContacts::CONTACT_TYPES.join('|')})_/ then 'wallet_contacts'
    else 'wallet_organization'
    end
  end
end
