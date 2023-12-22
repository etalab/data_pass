class AuthenticatedUserController < ApplicationController
  include Authentication
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    flash[:error] = {
      title: t('application.user_not_authorized.title')
    }

    redirect_to dashboard_path
  end
end
