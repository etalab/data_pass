class SessionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: [:create]

  def create
    if mon_compte_pro_connect?
      create_from_mon_compte_pro
    else
      create_from_proconnect
    end
  end

  def destroy
    @current_identity_federator = current_identity_federator

    sign_out

    redirect_to signout_url(@current_identity_federator), allow_other_host: true
  end

  private

  def create_from_mon_compte_pro
    authenticate_user(identity_federator: 'mon_compte_pro')

    case request.env['omniauth.params']['prompt']
    when 'select_organization'
      change_current_organization
    when 'update_userinfo'
      update_user
    else
      post_sign_in
    end
  end

  def create_from_proconnect
    return redirect_to_mfa_reauthentication if requires_mfa_reauthentication?

    complete_proconnect_sign_in
  end

  def redirect_to_mfa_reauthentication
    uri = OmniAuth::Strategies::Proconnect.authorization_uri_with_mfa(
      session:,
      login_hint: proconnect_raw_info['email']
    )
    redirect_to uri, allow_other_host: true
  end

  def complete_proconnect_sign_in
    organizer = authenticate_user(identity_federator: 'proconnect')
    user = organizer.user

    if user.current_identity_provider.choose_organization_on_sign_in?
      redirect_to user_organizations_path
    else
      post_sign_in
    end
  end

  def mon_compte_pro_connect?
    params[:provider] == 'mon_compte_pro'
  end

  def requires_mfa_reauthentication?
    identity_provider = IdentityProvider.find(proconnect_raw_info['idp_id'])

    identity_provider.mfa_required? && proconnect_id_token_amr.exclude?('mfa')
  end

  def proconnect_id_token_amr
    id_token = session['omniauth.pc.id_token']
    return [] unless id_token

    claims = JSON::JWT.decode(id_token, :skip_verification)
    claims['amr'] || []
  end

  def proconnect_raw_info
    request.env['omniauth.auth'].dig('extra', 'raw_info') || {}
  end

  def authenticate_user(identity_federator: 'mon_compte_pro')
    sign_out if user_signed_in?

    organizer = call_authenticator(identity_federator)
    sign_in(organizer.user, identity_federator:, identity_provider_uid: organizer.identity_provider_uid)

    organizer
  end

  def call_authenticator(identity_federator)
    case identity_federator
    when 'mon_compte_pro'
      AuthenticateUserThroughMonComptePro.call(mon_compte_pro_omniauth_payload: request.env['omniauth.auth'])
    when 'proconnect'
      AuthenticateUserThroughProConnect.call(pro_connect_omniauth_payload: request.env['omniauth.auth'])
    else
      raise ArgumentError, "Unknown identity federator: #{identity_federator}"
    end
  end

  def post_sign_in
    success_message(title: t('sessions.authenticate_user.success.title'))

    redirect_to redirect_to_after_sign_in
  end

  def change_current_organization
    ChangeCurrentOrganizationThroughMonComptePro.call(
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
    FindOrCreateUserThroughMonComptePro.call(
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

  def signout_url(current_identity_federator)
    case current_identity_federator
    when 'mon_compte_pro'
      mon_compte_pro_signout_url
    else
      proconnect_signout_url
    end
  end

  def proconnect_signout_url
    '/auth/proconnect/logout'
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
