module AuthorizationExtensions::WalletOrganization
  extend ActiveSupport::Concern

  HTTPS_URL_FORMAT = %r{\Ahttps://[^\s/.]+(\.[^\s/.]+)+(/\S*)?\z}
  EMAIL_FORMAT = /\A[^\s@]+@[^\s@]+\.[a-zA-Z]{2,}\z/
  SUPPORT_CHANNELS = %i[wallet_support_url wallet_support_email wallet_support_phone].freeze
  NATIONAL_PREFIX_AFTER_COUNTRY_CODE = /(\+\d{1,3})\s*\(\s*0\s*\)/
  POSTAL_ADDRESS_FORMAT = /\A(?=.{12,}).*\b\d{5}\b/m
  IDENTITY_SOURCES = %w[sirene non_diffusible sirene_pending sirene_unavailable].freeze

  included do
    include AuthorizationCore::DraftFormats
    include AuthorizationCore::Identity

    identity_from IdentitySources::Sirene

    add_attribute :wallet_privacy_policy_url
    add_attribute :wallet_website_url
    add_attribute :wallet_support_url
    add_attribute :wallet_support_email
    add_attribute :wallet_support_phone
    add_attribute :wallet_not_registered_elsewhere, type: :boolean
    add_attribute :wallet_postal_address
    add_documents :wallet_address_proof, content_type: ['application/pdf', 'image/png', 'image/jpeg'], size: { less_than: 10.megabytes }, limit: { max: 1 }

    before_validation :normalize_wallet_support_phone, prepend: true

    %i[wallet_privacy_policy_url wallet_website_url wallet_support_url].each do |attribute|
      draft_format(attribute, :wallet_https_format) { |value| HTTPS_URL_FORMAT.match?(value) }
    end
    draft_format(:wallet_support_email, :wallet_email_format) { |value| EMAIL_FORMAT.match?(value) }
    draft_format(:wallet_support_phone, :invalid_french_phone_format) { |value| FrenchPhoneNumberValidator.french_phone_number?(value) }
    draft_format(:wallet_postal_address, :wallet_postal_address_format) { |value| POSTAL_ADDRESS_FORMAT.match?(value) }

    with_options if: -> { need_complete_validation?(:wallet_organization) } do
      validates :wallet_privacy_policy_url, presence: true
      validate :wallet_support_channel_present
      validates :wallet_not_registered_elsewhere, acceptance: { accept: [true, 'true', '1'] }
    end

    validate :wallet_identity_loaded, on: :submit

    with_options if: -> { need_complete_validation?(:wallet_organization) && wallet_identity_entered_by_applicant? } do
      validates :wallet_postal_address, presence: true
      validates :wallet_address_proof, presence: true
    end
  end

  def wallet_identity_source
    IDENTITY_SOURCES.include?(identity_source) ? identity_source.to_sym : :sirene_unavailable
  end

  def wallet_organization_name
    identity_legal_name.presence || organization.name
  end

  def wallet_identity_entered_by_applicant?
    wallet_identity_source == :non_diffusible
  end

  def wallet_public_sector?
    identity_public_sector == 'true'
  end

  def applicant_capacity(executive_certified: nil)
    return :public_agent if wallet_public_sector?
    return :unknown if executive_certified.nil?

    executive_certified ? :executive : :executive_verification_required
  end

  def wallet_support
    SUPPORT_CHANNELS.map { |channel| public_send(channel) }.compact_blank
  end

  private

  def wallet_identity_loaded
    errors.add(:identity_source, :wallet_identity_pending) if identity_pending?
  end

  def wallet_support_channel_present
    return if wallet_support.any?

    errors.add(:wallet_support_url, :wallet_support_channel_missing)
  end

  def normalize_wallet_support_phone
    return if wallet_support_phone.blank?

    self.wallet_support_phone = wallet_support_phone
      .gsub(NATIONAL_PREFIX_AFTER_COUNTRY_CODE, '\1 ')
      .delete('()')
      .squish
  end
end
