class EuropeanWalletSubscriber < ApplicationRecord
  EXTERNAL_PROFILES = {
    'organization' => 'organisation',
    'intermediary' => 'intermediaire',
    'attestation_provider' => 'fournisseur_attestations',
  }.freeze

  enum :profile, EXTERNAL_PROFILES.keys.index_with(&:itself), validate: { allow_nil: true }

  encrypts :email, deterministic: true
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :profile, presence: true

  generates_token_for :unsubscribe

  def self.offered_profiles(registry_open:)
    registry_open ? profiles.keys - ['organization'] : profiles.keys
  end

  def external_profile
    EXTERNAL_PROFILES.fetch(profile)
  end
end
