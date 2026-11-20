module AuthorizationExtensions::WalletIntendedUses
  extend ActiveSupport::Concern

  INTENDED_USE_ERROR_ATTRIBUTE = /\Awallet_intended_uses_attributes_\d+_/
  INTENDED_USE_FORM_KEYS = [
    :id, :name, :purpose, :privacy_policy_url, :start_date, :end_date,
    { requested_attestations_attributes: [:id, { selected_claim_ids: [] }] }
  ].freeze
  RULEBOOK_PRELOADS = {
    summary: { rulebook: :claims },
    form: { rulebook: [:formats, { claims: :paths }] }
  }.freeze

  included do
    has_many :wallet_intended_uses,
      -> { order(:id).includes(requested_attestations: :requested_claims) },
      class_name: 'WalletRegistry::IntendedUse',
      foreign_key: :authorization_request_id,
      inverse_of: :authorization_request,
      dependent: :destroy,
      validate: false

    accepts_nested_attributes_for :wallet_intended_uses

    extra_nested_attributes[:wallet_intended_uses_attributes] = INTENDED_USE_FORM_KEYS

    with_options if: -> { need_complete_validation?(:wallet_intended_uses) } do
      validate :wallet_intended_use_present
      validate :wallet_intended_uses_valid
    end
  end

  def active_wallet_intended_uses
    wallet_intended_uses.reject(&:marked_for_destruction?)
  end

  def wallet_intended_uses_loaded_for(usage)
    active_wallet_intended_uses.tap do |uses|
      ActiveRecord::Associations::Preloader.new(records: uses.flat_map(&:attestations), associations: RULEBOOK_PRELOADS.fetch(usage)).call
    end
  end

  def read_attribute_for_validation(attribute)
    INTENDED_USE_ERROR_ATTRIBUTE.match?(attribute.to_s) ? nil : super
  end

  def wallet_intended_use(id)
    active_wallet_intended_uses.find { |use| use.id.to_s == id.to_s }
  end

  def wallet_registration_certificates_count
    active_wallet_intended_uses.size
  end

  private

  def wallet_intended_use_present
    errors.add(:wallet_intended_uses, :wallet_intended_uses_missing) if active_wallet_intended_uses.empty?
  end

  def wallet_intended_uses_valid
    active_wallet_intended_uses.each_with_index do |use, index|
      next if use.valid?

      use.errors.each { |error| add_wallet_intended_use_error(use, index, error) }
    end
  end

  def add_wallet_intended_use_error(use, index, error)
    field = error.options[:attestation_id] ? "attestation_#{error.options[:attestation_id]}" : error.attribute

    errors.add(
      :"wallet_intended_uses_attributes_#{index}_#{field}",
      :"wallet_intended_use_#{error.attribute}_#{error.type}",
      **error.options, message: error.message, use_name: use.display_name
    )
  end
end
