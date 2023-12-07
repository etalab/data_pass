class SessionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: [:create]

  def create
    organizer = AuthenticateUser.call(mon_compte_pro_omniauth_payload: request.env['omniauth.auth'])

    sign_in(organizer.user)

    redirect_to redirect_to_after_sign_in
  end

  def destroy
    sign_out

    redirect_to mon_compte_pro_signout_url, allow_other_host: true
  end

  private

  def after_logout_url
    root_url.sub(%r{/$}, '')
  end

  def mon_compte_pro_signout_url
    "#{Rails.application.credentials.mon_compte_pro_url}/oauth/logout?post_logout_redirect_uri=#{after_logout_url}&client_id=#{mon_compte_pro_api_gouv_client_id}"
  end

  def mon_compte_pro_api_gouv_client_id
    Rails.application.credentials.mon_compte_pro_client_id
  end

  def redirect_to_after_sign_in
    session.delete(:return_to_after_sign_in) || after_sign_in_path
  end
end
