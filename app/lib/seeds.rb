class Seeds
  STEPS = [
    :create_dem_commune_scenarios,
    Seeds::BoursiersHabilitationType,
    Seeds::OauthApplication,
    Seeds::VerifiedEmails,
    :create_stats_data,
    :create_historical_requests,
    :create_clamart_hubee_cert_dc_request,
    Seeds::MessageTemplates,
    Seeds::Webhooks,
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
