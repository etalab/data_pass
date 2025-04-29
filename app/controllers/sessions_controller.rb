class SessionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: [:create]

  def create
    if authenticate_user
      case request.env['omniauth.params']['prompt']
      when 'select_organization'
        change_current_organization
      when 'update_userinfo'
        update_user
      else
        post_sign_in
      end
    else
      warning_message(title: 'Impossible de se connecter avec ce compte sur cet environnment, merci de contacter le support')

      redirect_to root_path
    end
  end

  def destroy
    sign_out

    redirect_to mon_compte_pro_signout_url, allow_other_host: true
  end

  private

  def authenticate_user
    sign_out if user_signed_in?

    organizer = AuthenticateUser.call(mon_compte_pro_omniauth_payload: request.env['omniauth.auth'])

    return false if organizer.failure?

    sign_in(organizer.user)

    true
  end

  def post_sign_in
    success_message(title: t('sessions.authenticate_user.success.title'))

    redirect_to redirect_to_after_sign_in
  end

  def change_current_organization
    ChangeCurrentOrganization.call(
      user: current_user,
      mon_compte_pro_omniauth_payload: request.env['omniauth.auth'],
    )

    success_message(
      title: t('sessions.change_current_organization.success.title'),
      description: t('sessions.change_current_organization.success.description', organization_name: current_organization.name, organization_siret: current_organization.siret),
    )

    redirect_to after_prompt_path
  end

  def update_user
    FindOrCreateUser.call(
      mon_compte_pro_omniauth_payload: request.env['omniauth.auth'],
    )

    success_message(
      title: t('sessions.update_user.success.title')
    )

    redirect_to after_prompt_path
  end

  def after_prompt_path
    request.env['omniauth.origin'] || root_path
  end

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
