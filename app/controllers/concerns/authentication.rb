module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!

    helper_method :current_user, :current_organization, :user_signed_in? if respond_to?(:helper_method)
  end

  class_methods do
    def allow_unauthenticated_access(**)
      skip_before_action(:authenticate_user!, **)
    end

    alias_method :api_mode!, :allow_unauthenticated_access
  end

  def sign_in_path
    root_path
  end

  def sign_out_path
    root_path
  end

  def after_sign_in_path
    dashboard_path
  end

  def sign_in(user)
    session[:user_id] = {
      value: user.id,
      expires_at: 1.month.from_now
    }

    @current_user = user
  end

  def sign_out
    session.delete(:user_id)
    @current_user = nil
  end

  def authenticate_user!
    return if user_signed_in?

    session[:return_to_after_sign_in] = request.url
    redirect_to sign_in_path
  end

  def user_signed_in?
    valid_user_session? &&
      current_user.present?
  end

  def valid_user_session?
    user_id_session.present? &&
      user_id_session['value'].present? &&
      user_id_session['expires_at'].present? &&
      user_id_session['expires_at'] > Time.current
  end

  def user_id_session
    session[:user_id]
  end

  def save_redirect_path
    session[:return_to_after_sign_in] = request.url
  end

  def current_user
    @current_user ||= User.find_by(id: user_id_session.try(:[], 'value'))
  end

  def current_organization
    @current_organization ||= current_user&.current_organization
  end
end
