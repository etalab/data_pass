class AuthenticatedUserController < ApplicationController
  include Authentication
  include AccessAuthorization

  allow_unauthenticated_access only: :bypass_login

  def bypass_login
    return unless Rails.env.development?

    user = User.find_by(email: params[:email])
    sign_in(user)

    redirect_to dashboard_path
  end
end
