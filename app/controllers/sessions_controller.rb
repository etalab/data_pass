class SessionsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: [:create, :logout_callback]

  def create
    if mon_compte_pro_connect?
      create_from_mon_compte_pro
    else
      create_from_proconnect
    end
  end

  def destroy
    identity_federator = current_identity_federator
    
    # Build the logout URL before clearing session data
    logout_url = signout_url(identity_federator)
    
    # Clear local session
    sign_out

    # Redirect to identity provider logout
    redirect_to logout_url, allow_other_host: true
  end

  def logout_callback
    # Verify state parameter for CSRF protection (ProConnect only)
    # MonComptePro doesn't return a state parameter, so we allow both cases
    if params[:state].present?
      if params[:state] == session[:logout_state]
        # Clear session data
        session.delete(:logout_state)
        session.delete(:id_token)
        
        redirect_to root_path, notice: t('sessions.logout.success')
      else
        redirect_to root_path, alert: t('sessions.logout.invalid_state')
      end
    else
      # MonComptePro or direct access - just redirect to home
      session.delete(:logout_state)
      session.delete(:id_token)
      
      redirect_to root_path
    end
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
    # Note: we pass 'proconnect' but the organizer will set it to 'pro_connect'
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

  def authenticate_user(identity_federator: 'mon_compte_pro')
    sign_out if user_signed_in?

    organizer = call_authenticator(identity_federator)
    
    # Extract id_token from ProConnect credentials for logout
    # Note: The organizer sets identity_federator to 'pro_connect' (with underscore)
    id_token = if organizer.identity_federator == 'pro_connect'
      request.env['omniauth.auth']&.dig('credentials', 'id_token')
    end
    
    sign_in(organizer.user, identity_federator: organizer.identity_federator, identity_provider_uid: organizer.identity_provider_uid, id_token: id_token)

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
    logout_callback_url
  end

  def signout_url(current_identity_federator)
    case current_identity_federator
    when 'mon_compte_pro'
      mon_compte_pro_signout_url
    when 'pro_connect'
      proconnect_signout_url
    else
      # Fallback to ProConnect for unknown federators
      proconnect_signout_url
    end
  end

  def proconnect_signout_url
    proconnect_domain = Rails.application.credentials.proconnect_url
    
    # Generate a state parameter for CSRF protection
    logout_state = SecureRandom.hex(32)
    session[:logout_state] = logout_state
    
    # Build logout URL according to ProConnect documentation
    params = {
      id_token_hint: session[:id_token],
      state: logout_state,
      post_logout_redirect_uri: after_logout_url
    }
    
    "#{proconnect_domain}/api/v2/session/end?#{params.to_query}"
  end

  def mon_compte_pro_signout_url
    after_logout = ERB::Util.url_encode(after_logout_url)
    client_id = mon_compte_pro_api_gouv_client_id
    "#{Rails.application.credentials.mon_compte_pro_url}/oauth/logout?post_logout_redirect_uri=#{after_logout}&client_id=#{client_id}"
  end

  def mon_compte_pro_api_gouv_client_id
    Rails.application.credentials.mon_compte_pro_client_id
  end

  def redirect_to_after_sign_in
    session.delete(:return_to_after_sign_in) || after_sign_in_path
  end
end
