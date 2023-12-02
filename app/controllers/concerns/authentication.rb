module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!

    helper_method :current_user, :user_signed_in?
  end

  class_methods do
    def allow_unauthenticated_access(**)
      skip_before_action(:authenticate_user!, **)
    end
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

    redirect_to sign_out_path
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
    session[:user_id].present? &&
      session[:user_id]['value'].present? &&
      session[:user_id]['expires_at'].present? &&
      session[:user_id]['expires_at'] > Time.current
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id].try(:[], 'value'))
  end
end
