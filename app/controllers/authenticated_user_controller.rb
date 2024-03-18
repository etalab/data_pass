class AuthenticatedUserController < ApplicationController
  include Authentication
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  allow_unauthenticated_access only: :bypass_login

  def bypass_login
    return unless Rails.env.development?

    user = User.find_by(email: params[:email])
    sign_in(user)

    redirect_to dashboard_path
  end

  def pundit_user
    UserContext.new(current_user, request.host)
  end

  def user_not_authorized
    flash[:error] = {
      title: t('application.user_not_authorized.title')
    }

    redirect_to dashboard_path
  end
end
