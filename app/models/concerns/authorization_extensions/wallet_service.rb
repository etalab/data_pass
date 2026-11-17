module AuthorizationExtensions::WalletService
  extend ActiveSupport::Concern

  SERVICE_NAME_MAX_LENGTH = 50
  SERVICE_DESCRIPTION_MIN_LENGTH = 15
  SERVICE_IDENTIFIER_FORMAT = /\A[a-z0-9]+(-[a-z0-9]+)*\z/
  WORD_CHARACTER = /[\p{L}\p{N}]/
  ENTITLEMENT = 'Service_Provider'.freeze
  STATES_HOLDING_SERVICE_IDENTIFIER = %w[submitted changes_requested validated].freeze

  def self.propose_identifier(name)
    I18n.transliterate(name.to_s.downcase)
      .gsub(/[^a-z0-9]+/, '-')
      .gsub(/\A-+|-+\z/, '')
  end

  included do
    include AuthorizationCore::DraftFormats

    add_attribute :wallet_service_name
    add_attribute :wallet_service_identifier
    add_attribute :wallet_service_description

    before_validation :propose_wallet_service_identifier

    draft_format(:wallet_service_name, :wallet_service_name_too_long, options: ->(value) { { count: value.length } }) do |value|
      value.length <= SERVICE_NAME_MAX_LENGTH
    end
    draft_format(:wallet_service_identifier, :wallet_service_identifier_format) { |value| SERVICE_IDENTIFIER_FORMAT.match?(value) }
    draft_format(:wallet_service_description, :wallet_service_description_too_short) do |value|
      value.strip.length >= SERVICE_DESCRIPTION_MIN_LENGTH && WORD_CHARACTER.match?(value)
    end

    with_options if: -> { need_complete_validation?(:wallet_service) } do
      validates :wallet_service_name, presence: true
      validates :wallet_service_identifier, presence: true
      validates :wallet_service_description, presence: true
    end

    validate :wallet_service_identifier_available, if: -> { filling? && need_complete_validation?(:wallet_service) }
  end

  def wallet_entitlement
    ENTITLEMENT
  end

  private

  def propose_wallet_service_identifier
    return if wallet_service_identifier.present? || wallet_service_name.blank?

    self.wallet_service_identifier = AuthorizationExtensions::WalletService.propose_identifier(wallet_service_name)
  end

  def wallet_service_identifier_available
    return if wallet_service_identifier.blank?
    return unless requests_holding_wallet_service_identifier.exists?

    errors.add(:wallet_service_identifier, :wallet_service_identifier_taken)
  end

  def requests_holding_wallet_service_identifier
    self.class
      .where(state: STATES_HOLDING_SERVICE_IDENTIFIER)
      .where.not(id:)
      .where("authorization_requests.data -> 'wallet_service_identifier' = ?", wallet_service_identifier)
      .where(organization_id: organizations_sharing_wallet_service_identifiers)
  end

  def organizations_sharing_wallet_service_identifiers
    Organization.registered_in_insee_sirene.where('left(legal_entity_id, 9) = ?', organization_siren)
  end

  def organization_siren
    organization.siret&.first(9)
  end
end
