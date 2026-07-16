class LocalSignInPolicy
  def initialize(submitted_token: nil, unlocked_token: nil)
    @submitted_token = submitted_token
    @unlocked_token = unlocked_token
  end

  def available?
    return false if Rails.env.production?
    return true unless protected?

    matched_provider.present?
  end

  def unlockable_token
    @submitted_token if provider_for(@submitted_token)
  end

  def matched_provider
    provider_for(@submitted_token) || provider_for(@unlocked_token)
  end

  private

  def protected?
    configured_tokens.any?
  end

  def provider_for(token)
    return if token.blank?

    configured_tokens.find { |_provider, value|
      value.present? && ActiveSupport::SecurityUtils.secure_compare(token.to_s, value.to_s)
    }&.first
  end

  def configured_tokens
    tokens = Rails.application.credentials.local_sign_in_tokens
    tokens.is_a?(Hash) ? tokens : {}
  end
end
