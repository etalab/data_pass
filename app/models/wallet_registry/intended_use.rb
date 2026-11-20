class WalletRegistry::IntendedUse < ApplicationRecord
  PURPOSE_MIN_LENGTH = 15
  PURPOSE_MAX_LENGTH = 300
  WORD_CHARACTER = /[\p{L}\p{N}]/
  HTTPS_URL_FORMAT = AuthorizationExtensions::WalletOrganization::HTTPS_URL_FORMAT

  belongs_to :authorization_request, class_name: 'AuthorizationRequest::RegistreWallet', inverse_of: :wallet_intended_uses
  has_many :requested_attestations, -> { order(:id) }, class_name: 'WalletRegistry::IntendedUseAttestation', inverse_of: :intended_use, dependent: :destroy

  accepts_nested_attributes_for :requested_attestations

  validates :name, presence: true
  validate :purpose_well_written
  validate :privacy_policy_url_well_formed
  validate :data_requested
  validate :period_valid

  before_save :follow_organization_privacy_policy

  def self.sanitize(value)
    return if value.blank?

    CGI.unescapeHTML(Loofah.fragment(value.to_s).scrub!(:strip).to_text).strip.presence
  end

  def name=(value)
    super(self.class.sanitize(value))
  end

  def purpose=(value)
    super(self.class.sanitize(value))
  end

  def privacy_policy_url=(value)
    super(value.to_s.strip.presence)
  end

  def position
    authorization_request.active_wallet_intended_uses.index(self).to_i + 1
  end

  def display_name
    name.presence || I18n.t('wallet_registry.intended_use.unnamed', position:)
  end

  def default_privacy_policy_url
    authorization_request&.wallet_privacy_policy_url
  end

  def own_privacy_policy_url
    privacy_policy_url unless privacy_policy_url.blank? || privacy_policy_url == default_privacy_policy_url.to_s.strip
  end

  def effective_privacy_policy_url
    own_privacy_policy_url || default_privacy_policy_url
  end

  def attestations
    requested_attestations.reject(&:marked_for_destruction?)
  end

  def attestation_for(rulebook_id)
    attestations.find { |attestation| attestation.rulebook_id.to_s == rulebook_id.to_s }
  end

  def add_attestation(rulebook)
    attestation_for(rulebook.id) || requested_attestations.build(rulebook:)
  end

  def remove_attestation(rulebook_id)
    attestation_for(rulebook_id)&.mark_for_destruction
  end

  def credentials
    attestations.flat_map(&:credentials)
  end

  def claim_count
    attestations.sum(&:claim_count)
  end

  def claim_error_for(attestation)
    errors.where(:attestations, :no_claim).find { |error| error.options[:attestation_id] == attestation.rulebook_id }
  end

  private

  def follow_organization_privacy_policy
    self.privacy_policy_url = own_privacy_policy_url
  end

  def purpose_well_written
    text = purpose.to_s
    return errors.add(:purpose, :blank) if text.blank?
    return errors.add(:purpose, :too_long, count: text.length) if text.length > PURPOSE_MAX_LENGTH

    errors.add(:purpose, :too_short) if text.length < PURPOSE_MIN_LENGTH || !WORD_CHARACTER.match?(text)
  end

  def privacy_policy_url_well_formed
    url = effective_privacy_policy_url.to_s
    return errors.add(:privacy_policy_url, :blank) if url.blank?

    errors.add(:privacy_policy_url, :https_format) unless HTTPS_URL_FORMAT.match?(url)
  end

  def data_requested
    return errors.add(:attestations, :blank) if attestations.empty?

    attestations.select { |attestation| attestation.claim_count.zero? }.each do |attestation|
      errors.add(:attestations, :no_claim, attestation_id: attestation.rulebook_id, attestation_name: attestation.name)
    end
  end

  def period_valid
    return errors.add(:start_date, :blank) if start_date.nil?
    return errors.add(:start_date, :past) if start_date < Date.current

    errors.add(:end_date, :before_start_date) if end_date && end_date <= start_date
  end
end
