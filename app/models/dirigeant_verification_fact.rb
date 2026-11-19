class DirigeantVerificationFact
  SESSION_KEY = :dirigeant_verification
  VALIDITY = 1.hour

  attr_reader :user_id, :siret, :verified_at

  def self.build(user:, organization:, verified_at: Time.zone.now)
    new(user_id: user.id, siret: organization.siret, verified_at:)
  end

  def self.from_session(value)
    return if value.blank?

    new(user_id: value['user_id'], siret: value['siret'], verified_at: Time.zone.parse(value['verified_at'].to_s))
  end

  def initialize(user_id:, siret:, verified_at:)
    @user_id = user_id
    @siret = siret
    @verified_at = verified_at
  end

  def valid_for?(user:, organization:, now: Time.zone.now)
    user.present? &&
      organization.present? &&
      user_id == user.id &&
      siret == organization.siret &&
      fresh?(now)
  end

  def to_session
    { 'user_id' => user_id, 'siret' => siret, 'verified_at' => verified_at.iso8601 }
  end

  private

  def fresh?(now)
    verified_at.present? && verified_at <= now && verified_at > now - VALIDITY
  end
end
