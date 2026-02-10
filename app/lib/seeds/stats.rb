class Seeds::Stats
  AUTHORIZATION_TYPES_PER_PROVIDER = {
    'dgs' => %i[portail_hubee_demarche_certdc],
    'dila' => %i[hubee_dila],
    'dinum' => %i[api_entreprise france_connect api_particulier le_taxi pro_connect_fs annuaire_des_entreprises],
    'dgfip' => %i[api_impot_particulier_sandbox api_sfip_sandbox api_ficoba_sandbox],
    'aife' => %i[api_captchetat],
    'ans' => %i[api_pro_sante_connect],
    'urssaf' => %i[api_declaration_auto_entrepreneur],
    'menj' => %i[api_scolarite api_gfe_echange_collectivites],
    'cnam' => %i[api_indemnites_journalieres_cnam],
    'cisirh' => %i[services_cisirh],
    'mtes' => %i[api_mobilic],
    'dge' => %i[aides_etat]
  }.freeze

  FORMS_PER_TYPE = {
    api_entreprise: %w[api-entreprise api-entreprise-marches-publics api-entreprise-aides-publiques],
    api_particulier: %w[api-particulier api-particulier-aiga api-particulier-entrouvert-publik],
    france_connect: %w[france-connect france-connect-collectivite-administration]
  }.freeze

  def initialize(seeds)
    @seeds = seeds
  end

  def perform
    create_requests_for_all_providers
    create_multi_form_requests
    create_time_spread_requests
  end

  private

  def create_requests_for_all_providers
    AUTHORIZATION_TYPES_PER_PROVIDER.each_value do |types|
      types.each do |type|
        create_authorization_requests_for_type(type)
      end
    end
  end

  def create_authorization_requests_for_type(type)
    create_with_state(:submitted, type, target_date: rand(1..11).months.ago)
    create_with_state(:validated, type, target_date: rand(1..11).months.ago)
    create_with_state(:refused, type, target_date: rand(1..11).months.ago)
    create_with_state(:validated_after_changes, type, target_date: rand(1..11).months.ago)
  end

  def create_multi_form_requests
    FORMS_PER_TYPE.each do |type, form_uids|
      form_uids.each do |form_uid|
        create_with_state(:validated, type, form_uid: form_uid, target_date: rand(1..11).months.ago)
      end
    end
  end

  def create_time_spread_requests
    (1..12).each do |months_ago|
      type = AUTHORIZATION_TYPES_PER_PROVIDER.values.flatten.sample
      create_with_state(:validated, type, target_date: months_ago.months.ago)
      create_with_state(:submitted, type, target_date: months_ago.months.ago)
    end
  end

  def create_with_state(state, type, form_uid: nil, target_date: Time.current)
    attributes = { applicant: applicant }
    attributes[:form_uid] = form_uid if form_uid

    authorization_request = build_authorization_request(state, type, attributes)
    return unless authorization_request

    backdate_request_and_events(authorization_request, target_date)
  rescue StandardError => e
    Rails.logger.warn("Stats seed: skipping #{state} #{type} - #{e.message}")
  end

  def build_authorization_request(state, type, attributes)
    case state
    when :submitted
      @seeds.send(:create_submitted_authorization_request, type, attributes:)
    when :validated
      @seeds.send(:create_validated_authorization_request, type, attributes:)
    when :refused
      @seeds.send(:create_refused_authorization_request, type, attributes:)
    when :validated_after_changes
      create_validated_after_changes(type, attributes)
    end
  end

  def create_validated_after_changes(type, attributes)
    authorization_request = @seeds.send(:create_request_changes_authorization_request, type, attributes:)
    user = authorization_request.applicant
    instructor = @seeds.send(:api_entreprise_instructor)

    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user:)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: instructor)

    authorization_request
  end

  def backdate_request_and_events(authorization_request, target_date)
    authorization_request.update_columns(created_at: target_date, updated_at: target_date) # rubocop:disable Rails/SkipsModelValidations

    ensure_create_event(authorization_request)

    events = AuthorizationRequestEvent
      .where(authorization_request_id: authorization_request.id)
      .order(:id)
      .to_a
      .sort_by { |e| e.name == 'create' ? 0 : 1 }

    running_date = target_date
    events.each do |event|
      running_date += rand(2..5).days + rand(1..48).hours
      event.update_columns(created_at: running_date, updated_at: running_date) # rubocop:disable Rails/SkipsModelValidations
    end
  end

  def ensure_create_event(authorization_request)
    return if AuthorizationRequestEvent.exists?(authorization_request_id: authorization_request.id, name: 'create')

    AuthorizationRequestEvent.create!(
      name: 'create',
      user: authorization_request.applicant,
      entity: authorization_request,
      authorization_request: authorization_request
    )
  end

  def applicant
    @seeds.send(:demandeur)
  end
end
