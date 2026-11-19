class DirigeantVerificationsController < AuthenticatedUserController
  include LocalReturnPath

  SECTOR_REFUSAL = { 'status' => 'failure', 'reason' => 'organization_is_public_service' }.freeze
  DISPLAYED_VERIFICATION_ATTRIBUTES = %w[siren siret acr amr verified_at].freeze

  before_action :ensure_dirigeant_verification_enabled

  allow_unauthenticated_access only: :show

  def show
    @organization = current_organization
    @verification_allowed = !user_signed_in? || verification_allowed?
    @result = flash[:dirigeant_verification] || (SECTOR_REFUSAL unless @verification_allowed)
    @return_to = local_return_path(params[:return_to])
  end

  def create
    return redirect_to dirigeant_verification_path(return_to: local_return_to), flash: { dirigeant_verification: SECTOR_REFUSAL } unless verification_allowed?

    organizer = verify_dirigeant

    report_rejection(organizer.error) if organizer.failure?

    flash[:dirigeant_verification] = verification_result(organizer)
    redirect_to path_after_verification
  end

  private

  def verify_dirigeant
    VerifyDirigeantThroughProConnect.call(
      user: current_user,
      organization: current_organization,
      pro_connect_omniauth_payload: request.env['omniauth.auth']
    )
  end

  def path_after_verification
    local_return_to || dirigeant_verification_path
  end

  def local_return_to
    local_return_path(request.env.dig('omniauth.params', 'return_to'))
  end

  def verification_allowed?
    OrganizationPolicy.new(pundit_user, current_organization).verify_dirigeant?
  end

  def ensure_dirigeant_verification_enabled
    head :not_found unless FeatureFlag.enabled?(:proconnect_dirigeant)
  end

  def verification_result(organizer)
    if organizer.success?
      { 'status' => 'success', 'details' => organizer.verification.as_json.slice(*DISPLAYED_VERIFICATION_ATTRIBUTES) }
    else
      { 'status' => 'failure', 'reason' => organizer.error.to_s }
    end
  end

  def report_rejection(reason)
    Sentry.capture_message('ProConnect dirigeant verification rejected', level: :info, extra: { reason: })
  end

  def model_to_track_for_impersonation
    current_user
  end
end
