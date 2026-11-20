module WalletRegistryEntry
  extend ActiveSupport::Concern

  include WalletRegistryAnswer

  DIRIGEANT_VERIFICATION_REFUSALS = {
    'acr_not_dirigeant' => 'executive_not_certified',
    'proconnect_error' => 'executive_not_certified',
    'siret_outside_siren' => 'executive_siret_outside_siren',
    'identity_mismatch' => 'executive_identity_mismatch',
    'organization_without_siren' => 'executive_organization_without_siren'
  }.freeze

  private

  def wallet_registry_form?
    @authorization_request_form.authorization_definition.wallet_registry? &&
      @authorization_request_form.startable_by_applicant
  end

  def enter_wallet_registry
    if user_signed_in? && wallet_registry_violation.nil?
      render_wallet_registry_introduction
    elsif user_signed_in? || wallet_registry_answer
      render_wallet_registry_start
    else
      redirect_to new_authorization_request_path(definition_id: @authorization_request_form.authorization_definition.id)
    end
  end

  def guard_wallet_registry_start
    redirect_to authorization_request_form_introduction_path(form_uid: @authorization_request_form.uid) if wallet_registry_violation
  end

  def render_wallet_registry_introduction
    @wallet_registry_capacity = policy(@authorization_request_form).applicant_eligibility.capacity

    render 'authorization_request_forms/registre_wallet/new', layout: 'form_introduction'
  end

  def render_wallet_registry_start
    save_redirect_path

    @authorization_definition = @authorization_request_form.authorization_definition
    @wallet_registry_sign_in = build_wallet_registry_sign_in(violation: (wallet_registry_violation if user_signed_in?))
    @wallet_registry_refusal = wallet_registry_refusal
    @wallet_registry_start_renders_alerts = true

    render 'authorization_requests/unauthenticated_start', layout: 'authorization_request'
  end

  def wallet_registry_refusal
    dirigeant_verification = flash[:dirigeant_verification]
    return DIRIGEANT_VERIFICATION_REFUSALS.fetch(dirigeant_verification['reason'], 'default') if dirigeant_verification&.dig('status') == 'failure'

    signed_in_wallet_registry_refusal if user_signed_in?
  end

  def signed_in_wallet_registry_refusal
    return :executive_certification_unavailable if wallet_registry_violation == :executive_certification_required && !@wallet_registry_sign_in.executive_journey_open?
    return :organization_check_pending if wallet_registry_violation == :organization_closed && current_organization.insee_refresh_due?

    wallet_registry_violation
  end

  def wallet_registry_violation
    @wallet_registry_violation ||= policy(@authorization_request_form).access_violation
  end
end
