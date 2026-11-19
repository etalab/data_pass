class WalletRegistry::SubmissionIntent
  SESSION_KEY = :wallet_registry_submission_intent
  VALIDITY = 15.minutes

  attr_reader :authorization_request_id, :user_id, :nonce, :created_at

  def self.issue(authorization_request:, user:, now: Time.zone.now)
    new(authorization_request_id: authorization_request.id, user_id: user.id, nonce: SecureRandom.urlsafe_base64(24), created_at: now)
  end

  def self.from_session(value)
    return if value.blank?

    new(
      authorization_request_id: value['authorization_request_id'],
      user_id: value['user_id'],
      nonce: value['nonce'],
      created_at: Time.zone.parse(value['created_at'].to_s)
    )
  end

  def initialize(authorization_request_id:, user_id:, nonce:, created_at:)
    @authorization_request_id = authorization_request_id
    @user_id = user_id
    @nonce = nonce
    @created_at = created_at
  end

  def valid_for?(authorization_request:, user:, nonce:, now: Time.zone.now)
    authorization_request_id == authorization_request.id &&
      user_id == user.id &&
      nonce.present? &&
      ActiveSupport::SecurityUtils.secure_compare(self.nonce.to_s, nonce.to_s) &&
      created_at.present? &&
      created_at > now - VALIDITY
  end

  def certified_after_issue?(dirigeant_verification)
    dirigeant_verification.present? &&
      dirigeant_verification.verified_at.present? &&
      dirigeant_verification.verified_at >= created_at.change(usec: 0)
  end

  def to_session
    { 'authorization_request_id' => authorization_request_id, 'user_id' => user_id, 'nonce' => nonce, 'created_at' => created_at.iso8601(6) }
  end
end
