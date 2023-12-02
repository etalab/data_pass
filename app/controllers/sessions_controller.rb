class SessionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: [:create]

  def create
    user = User.find_or_create_from_mon_compte_pro(request.env['omniauth.auth'])

    sign_in(user)

    redirect_to redirect_to_after_sign_in
  end

  private

  def redirect_to_after_sign_in
    session.delete(:return_to_after_sign_in) || after_sign_in_path
  end
end
