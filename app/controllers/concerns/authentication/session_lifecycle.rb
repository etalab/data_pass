module Authentication::SessionLifecycle
  SESSION_MAX_DURATION = 12.hours

  ROTATION_PRESERVED_KEYS = %w[
    omniauth.pc.access_token
    omniauth.pc.id_token
    omniauth.pc.refresh_token
    return_to_after_sign_in
  ].freeze

  def self.valid_session?(user_id_session)
    user_id_session.present? &&
      user_id_session['value'].present? &&
      future_timestamp?(user_id_session['expires_at'])
  end

  def self.future_timestamp?(timestamp)
    time = normalize_timestamp(timestamp)
    time.present? && time > Time.current
  end

  def self.normalize_timestamp(timestamp)
    return Time.zone.parse(timestamp) if timestamp.is_a?(String)

    timestamp
  rescue ArgumentError
    nil
  end

  def valid_user_session? = Authentication::SessionLifecycle.valid_session?(user_id_session)

  def session_expired?
    user_id_session.present? && !valid_user_session?
  end

  def user_id_session
    session[:user_id]
  end

  private

  def rotate_session
    preserved = session.to_hash.slice(*ROTATION_PRESERVED_KEYS)
    reset_session
    preserved.each { |key, value| session[key] = value }
  end
end
