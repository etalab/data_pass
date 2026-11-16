class EuropeanWalletSubscriber < ApplicationRecord
  EXTERNAL_PROFILES = {
    'organization' => 'organisation',
    'intermediary' => 'intermediaire',
    'attestation_provider' => 'fournisseur_attestations',
  }.freeze

  enum :profile, EXTERNAL_PROFILES.keys.index_with(&:itself), validate: { allow_nil: true }

  encrypts :email, deterministic: true
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :profile, presence: true

  generates_token_for :unsubscribe

  def external_profile
    EXTERNAL_PROFILES.fetch(profile)
  end
end
