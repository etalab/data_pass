module LocalSignInProtection
  extend ActiveSupport::Concern

  LOCAL_SIGN_IN_COOKIE = :local_sign_in_token

  included do
    helper_method :local_sign_in_panel_visible?
  end

  private

  def authorize_local_sign_in
    policy = LocalSignInPolicy.new(
      submitted_token: params[:token],
      unlocked_token: cookies.signed[LOCAL_SIGN_IN_COOKIE]
    )
    return false unless policy.available?

    if (token = policy.unlockable_token)
      cookies.signed[LOCAL_SIGN_IN_COOKIE] = { value: token, httponly: true, expires: 30.days }
    end
    log_local_sign_in(policy.matched_provider)
    true
  end

  def log_local_sign_in(provider)
    return unless provider

    Rails.logger.info(
      "[local-sign-in] accès via le token « #{provider} » — email=#{params[:email]} ip=#{request.remote_ip}"
    )
  end

  def local_sign_in_panel_visible?
    LocalSignInPolicy.new(unlocked_token: cookies.signed[LOCAL_SIGN_IN_COOKIE]).available?
  end
end
