class Seeds
  STEPS = [
    :create_dem_commune_scenarios,
    Seeds::BoursiersHabilitationType,
    Seeds::OauthApplication,
    :create_all_verified_emails,
    :create_stats_data,
    :create_historical_requests,
    :create_clamart_hubee_cert_dc_request,
    Seeds::MessageTemplates,
    :create_webhooks,
  ].freeze

  def perform
    create_data_providers
    create_organizations_and_accounts

    STEPS.each do |step|
      step.is_a?(Symbol) ? send(step) : step.new(context).perform
    end
  end

  def flushdb
    raise 'Not in production!' if production?

    connection = ActiveRecord::Base.connection

    connection.tables.each do |table|
      next if %w[schema_migrations ar_internal_metadata].include?(table)

      connection.execute("TRUNCATE TABLE #{connection.quote_table_name(table)} RESTART IDENTITY CASCADE;")
    end

    flush_unread_messages_counters
  end

  def create_data_providers
    seeds_for(:data_providers).each do |slug, attributes|
      provider = DataProvider.find_or_initialize_by(
        slug: slug.to_s,
      )

      provider.assign_attributes(
        name: attributes[:name],
        link: attributes[:link]
      )

      provider.save!(validate: false)

      provider.logo.attach(
        io: Rails.root.join('app', 'assets', 'images', 'data_providers', attributes[:logo]).open,
        filename: attributes[:logo],
      )

      provider.save!
    end
  end

  private

  def create_historical_requests
    requests.create_validated_authorization_request(:api_entreprise, attributes: { intitule: 'Portail des appels d’offres', applicant: dem_historique, external_provider_id: 'e5b4c2d1-8f3a-4b6e-9c7d-1a2b3c4d5e6f' })

    authorization_request = requests.create_request_changes_authorization_request(:api_entreprise, attributes: { intitule: 'Portail des aides publiques', applicant: dem_multi_orga })
    send_message_to_instructors(authorization_request, body: 'Bonjour, je ne suis pas sûr du cadre légal de cette demande, pouvez-vous m\'aider ?')
    send_message_to_applicant(authorization_request, body: 'Bonjour, il faut que vous demandiez à votre DPO de vous fournir le document inférent à votre demande.')

    authorization_request = requests.create_submitted_authorization_request(:api_entreprise, attributes: { intitule: 'Place des entreprises', applicant: dem_multi_orga })
    send_message_to_instructors(authorization_request, body: 'Je ne suis pas sûr du cadre de cette demande, pouvez-vous m’aider ?')

    create_api_particulier_with_france_connect_embedded_fields
    create_fully_approved_api_impot_particulier_authorization_request
    create_authorization_request_with_old_authorization
  end

  def create_authorization_request_with_old_authorization
    authorization_request = requests.create_reopened_authorization_request(:api_entreprise, attributes: { intitule: 'Habilitation mise à jour', applicant: dem_historique })
    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user: dem_historique)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: requests.instructor_for(authorization_request))
    authorization_request
  end

  protected

  def organizations
    @organizations ||= Seeds::ReferenceOrganizations.new
  end

  def accounts
    @accounts ||= Seeds::TestAccounts.new(organizations)
  end

  def requests
    @requests ||= Seeds::AuthorizationRequestInState.new(accounts)
  end

  def context
    @context ||= Seeds::Context.new(organizations:, accounts:, requests:)
  end

  private

  def create_organizations_and_accounts
    organizations.perform
    accounts.perform
  end

  def dem_historique = accounts.dem_historique

  def dem_multi_orga = accounts.dem_multi_orga

  def create_clamart_hubee_cert_dc_request
    requests.create_validated_authorization_request(:portail_hubee_demarche_certdc, attributes: { description: nil, applicant: dem_historique })
  end

  def create_api_particulier_with_france_connect_embedded_fields
    authorization_request = FactoryBot.create(
      :authorization_request,
      :api_particulier,
      :with_france_connect_embedded_fields,
      fill_all_attributes: true,
      form_uid: 'api-particulier-aiga',
      applicant: dem_historique,
      organization: dem_historique.current_organization,
      intitule: 'Portail famille avec FranceConnect unifié',
      description: requests.random_description
    )

    SubmitAuthorizationRequest.call(authorization_request:, user: dem_historique)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: requests.instructor_for(authorization_request))

    authorization_request
  end

  # rubocop:disable-next Metrics/AbcSize
  def create_fully_approved_api_impot_particulier_authorization_request
    authorization_request = requests.create_validated_authorization_request(:api_impot_particulier_sandbox, attributes: { intitule: 'PASS FAMILLE', applicant: dem_historique, created_at: 3.days.ago })

    StartNextAuthorizationRequestStage.call(authorization_request: authorization_request, user: authorization_request.applicant).perform

    authorization_request = AuthorizationRequest.find(authorization_request.id)

    valid_api_impot_particulier_production = FactoryBot.build(:authorization_request, :api_impot_particulier_production, applicant: authorization_request.applicant, organization: authorization_request.organization, fill_all_attributes: true)

    valid_api_impot_particulier_production.class.extra_attributes.each do |key|
      authorization_request.public_send(:"#{key}=", valid_api_impot_particulier_production.public_send(key))
    end
    authorization_request.safety_certification_document.attach([requests.dummy_file])
    authorization_request.terms_of_service_accepted = true
    authorization_request.data_protection_officer_informed = true
    authorization_request.dpd_homologation_checkbox = '1'

    authorization_request.save!

    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user: authorization_request.applicant)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: requests.instructor_for(authorization_request))

    raise 'Authorization request not validated' unless authorization_request.reload.validated?
  end

  def create_all_verified_emails
    User.find_each do |user|
      create_verified_email(user.email, 'deliverable')
    end

    create_verified_email('unknown-but-whitelisted@wanadoo.fr', 'whitelisted')

    AuthorizationRequest.find_each do |authorization_request|
      authorization_request.class.contact_types.each do |contact_type|
        create_verified_email(authorization_request.send(:"#{contact_type}_email"), 'deliverable')
      end
    end
  end

  def create_verified_email(email, status)
    return if email.blank?
    return if VerifiedEmail.exists?(email:)

    VerifiedEmail.create!(
      email:,
      status:,
      verified_at: Time.zone.now,
    )
  end

  def send_message_to_instructors(authorization_request, message_params)
    SendMessageToInstructors.call(
      authorization_request:,
      user: authorization_request.applicant,
      message_params:,
    )

    authorization_request.mark_messages_as_read_by_applicant!
  end

  def send_message_to_applicant(authorization_request, message_params)
    SendMessageToApplicant.call(
      authorization_request:,
      user: requests.instructor_for(authorization_request),
      message_params:,
    )
    authorization_request.mark_messages_as_read_by_instructors!
  end

  def load_all_models!
    Rails.root.glob('app/models/**/*.rb').each { |f| require f }
  end

  def seeds_for(name)
    YAML.load(Rails.root.join('db', 'seeds', "#{name}.yml").read, aliases: true).deep_symbolize_keys[:shared]
  end

  def create_webhooks
    create_api_entreprise_webhooks
  end

  def create_api_entreprise_webhooks
    webhook_valid = Webhook.create!(
      authorization_definition_id: 'api_entreprise',
      url: 'http://localhost:3000/dummy/valid/webhooks',
      secret: SecureRandom.hex(32),
      events: %w[create update submit approve refuse revoke],
      validated: true,
      enabled: true
    )

    webhook_invalid = Webhook.create!(
      authorization_definition_id: 'api_entreprise',
      url: 'http://localhost:3000/dummy/invalid/webhooks',
      secret: SecureRandom.hex(32),
      events: %w[submit approve refuse],
      validated: false,
      enabled: false
    )

    create_webhook_attempts_for_api_entreprise(webhook_valid, webhook_invalid)
  end

  def create_webhook_attempts_for_api_entreprise(webhook_valid, webhook_invalid)
    authorization_requests = AuthorizationRequest.where(form_uid: 'api-entreprise').limit(5)

    authorization_requests.each_with_index do |authorization_request, index|
      create_successful_webhook_attempts(webhook_valid, webhook_invalid, authorization_request, index)
    end

    create_failed_webhook_attempts(webhook_valid, authorization_requests.first)
  end

  def create_successful_webhook_attempts(webhook_valid, webhook_invalid, authorization_request, index)
    WebhookAttempt.create!(
      webhook: webhook_valid,
      authorization_request: authorization_request,
      event_name: 'submit',
      status_code: 200,
      response_body: '{"token_id":"abc123"}',
      payload: { event: 'submit', id: authorization_request.id },
      created_at: index.days.ago
    )

    WebhookAttempt.create!(
      webhook: webhook_invalid,
      authorization_request: authorization_request,
      event_name: 'approve',
      status_code: 422,
      response_body: '{"hello":"world"}',
      payload: { event: 'approve', id: authorization_request.id },
      created_at: index.days.ago
    )
  end

  def create_failed_webhook_attempts(webhook, authorization_request)
    return unless authorization_request

    WebhookAttempt.create!(
      webhook: webhook,
      authorization_request: authorization_request,
      event_name: 'update',
      status_code: 500,
      response_body: '{"error":"Internal server error"}',
      payload: { event: 'update', id: authorization_request.id },
      created_at: 1.hour.ago
    )

    WebhookAttempt.create!(
      webhook: webhook,
      authorization_request: authorization_request,
      event_name: 'update',
      status_code: 404,
      response_body: '{"error":"Not found"}',
      payload: { event: 'update', id: authorization_request.id },
      created_at: 30.minutes.ago
    )
  end

  def flush_unread_messages_counters
    redis = Kredis.configured_for(:shared)
    counter_keys = redis.scan_each(match: Kredis.namespaced_key('authorization_request:*:redis_unread_messages_*')).to_a

    redis.del(*counter_keys) if counter_keys.any?
  end

  def production?
    Rails.env.production? && ENV['CAN_FLUSH_DB'].blank?
  end

  def create_dem_commune_scenarios
    Seeds::DemCommuneScenarios.new(self).perform
  end

  def create_stats_data
    Seeds::Stats.new(self).perform
  end
end
