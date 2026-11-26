class WalletRegistryStart
  ANSWERS = %w[dirigeant agent].freeze

  VERIFICATION_FAILURE_REFUSALS = {
    'acr_not_dirigeant' => :executive_not_certified,
    'proconnect_error' => :executive_not_certified,
    'siret_outside_siren' => :executive_siret_outside_siren,
    'identity_mismatch' => :executive_identity_mismatch,
    'organization_without_siren' => :executive_organization_without_siren
  }.freeze

  def initialize(answer:, violation:, verification:, organization:, signed_in:)
    @answer = answer.presence_in(ANSWERS)
    @violation = violation
    @verification = verification
    @organization = organization
    @signed_in = signed_in
  end

  attr_reader :answer

  def answer_key
    return 'dirigeant_without_certification' if answer == 'dirigeant' && !executive_journey_open?

    answer
  end

  def refusal
    return VERIFICATION_FAILURE_REFUSALS.fetch(verification_failure, :default) if verification_failure

    access_refusal if signed_in?
  end

  def pro_connect_locals(return_to:)
    locals = { return_to:, title: nil, wrapper_class: nil }

    return locals unless executive_sign_in?
    return locals.merge(hidden_fields: { parcours: 'dirigeant' }) unless signed_in?

    locals.merge(identity_federator: 'proconnect_dirigeant', hidden_fields: { siret_hint: organization&.siret })
  end

  private

  attr_reader :violation, :verification, :organization

  def signed_in?
    @signed_in
  end

  def verification_failure
    verification['reason'] if verification&.dig('status') == 'failure'
  end

  def access_refusal
    return :executive_certification_unavailable if violation == :executive_certification_required && !executive_journey_open?
    return :organization_check_pending if violation == :organization_closed && organization.insee_refresh_due?

    violation
  end

  def executive_sign_in?
    executive_journey_open? && (answer == 'dirigeant' || violation == :executive_certification_required)
  end

  def executive_journey_open?
    FeatureFlag.enabled?(:proconnect_dirigeant)
  end
end
