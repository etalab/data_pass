module ProConnectDirigeantJourney
  extend ActiveSupport::Concern

  include LocalReturnPath

  private

  def redirect_dirigeant_verification_failure
    session.delete(DirigeantVerificationFact::SESSION_KEY)
    flash[:dirigeant_verification] = { 'status' => 'failure', 'reason' => params[:message].to_s }
    redirect_to local_return_path(params[:origin]) || dirigeant_verification_path
  end

  def dirigeant_journey?
    request.env.dig('omniauth.params', 'parcours') == 'dirigeant'
  end

  def start_dirigeant_verification(organization)
    return redirect_to dirigeant_verification_path(return_to: dirigeant_return_to) unless dirigeant_verification_allowed?(organization)

    session[OmniAuth::Strategies::ProconnectDirigeant::CHAINED_REQUEST_SESSION_KEY] = Time.now.to_i
    chained_params = { siret_hint: organization.siret, return_to: dirigeant_return_to }.compact_blank

    redirect_to "/auth/proconnect_dirigeant?#{chained_params.to_query}"
  end

  def dirigeant_verification_allowed?(organization)
    user_context = UserContext.new(current_user, request.host, authentication_session: session[:user_id])

    OrganizationPolicy.new(user_context, organization).start_dirigeant_verification?
  end

  def dirigeant_return_to
    request.env.dig('omniauth.params', 'return_to').presence
  end
end
