class Seeds
  def perform
    create_data_providers
    create_entities
    create_oauth_app
    create_all_verified_emails

    create_authorization_requests_for_clamart
    create_authorization_requests_for_dinum
    create_validated_authorization_request(:portail_hubee_demarche_certdc, attributes: { description: nil })
    create_instructor_draft_request(applicant: demandeur)
    create_message_templates
    create_webhooks
    create_stats_data
  end

  def flushdb
    raise 'Not in production!' if production?

    ActiveRecord::Base.connection.tables.each do |table|
      next if %w[schema_migrations ar_internal_metadata].include?(table)

      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
    end
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

  # rubocop:disable Metrics/AbcSize
  def create_entities
    verified_params = {
      verified: true,
      identity_federator: 'pro_connect',
      identity_provider_uid: IdentityProvider::PRO_CONNECT_IDENTITY_PROVIDER_UID,
    }

    demandeur.add_to_organization(clamart_organization, current: true, **verified_params)
    another_demandeur.add_to_organization(clamart_organization, current: true, **verified_params)
    another_demandeur.add_to_organization(dinum_organization, current: true, verified: false)

    api_entreprise_instructor.add_to_organization(dinum_organization, current: true, **verified_params)
    api_entreprise_reporter.add_to_organization(dinum_organization, current: true, **verified_params)
    foreign_demandeur.add_to_organization(dinum_organization, current: true, verified: false)
    data_pass_admin.add_to_organization(dinum_organization, current: true, **verified_params)
    dgfip_instructor_developer.add_to_organization(dinum_organization, current: true, **verified_params)
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_authorization_requests_for_clamart
    create_validated_authorization_request(:api_entreprise, attributes: { intitule: "Portail des appels d'offres", applicant: demandeur })
    france_connect_authorization_request = create_validated_authorization_request(
      :france_connect,
      attributes: { intitule: 'Connexion FranceConnect', applicant: demandeur },
      authorization_message: "Vous pouvez maintenant procéder à l'intégration technique."
    )
    create_validated_authorization_request(:api_droits_cnam, attributes: { france_connect_authorization_id: france_connect_authorization_request.latest_authorization.id, applicant: demandeur })

    authorization_request = create_request_changes_authorization_request(:api_entreprise, attributes: { intitule: 'Portail des aides publiques', applicant: another_demandeur })
    send_message_to_instructors(authorization_request, body: 'Bonjour, je ne suis pas sûr du cadre légal de cette demande, pouvez-vous m\'aider ?')
    send_message_to_applicant(authorization_request, body: 'Bonjour, il faut que vous demandiez à votre DPO de vous fournir le document inférent à votre demande.')

    authorization_request = create_request_changes_authorization_request(:api_entreprise, attributes: { intitule: 'Portail des aides dans le secteur du bâtiment' })
    send_message_to_instructors(authorization_request, body: 'Bonjour, dois-je inclure les aides pour les particuliers ?')
    send_message_to_applicant(authorization_request, body: 'Bonjour, non il s\'agit uniquement des aides pour les entreprises.')

    create_refused_authorization_request(:api_entreprise, attributes: { intitule: 'Statistiques sur les effectifs', applicant: demandeur })
    create_revoked_authorization_request(:api_entreprise, attributes: { intitule: 'Loi énérgie', applicant: demandeur })
    create_reopened_authorization_request(:api_entreprise_mgdis, attributes: { applicant: demandeur })

    authorization_request = create_submitted_authorization_request(:api_entreprise, attributes: { intitule: 'Place des entreprises', applicant: another_demandeur })
    send_message_to_instructors(authorization_request, body: "Je ne suis pas sûr du cadre de cette demande, pouvez-vous m'aider ?")

    create_validated_authorization_request(:api_impot_particulier_sandbox, attributes: { intitule: 'Demande de retraite progressive en ligne', applicant: demandeur })

    france_connect_authorization_request_for_dgfip = create_validated_authorization_request(:france_connect, attributes: { intitule: 'Connexion FranceConnect ImpotPart', applicant: demandeur })
    create_validated_authorization_request(:api_impot_particulier_sandbox, attributes: { modalities: ['with_france_connect'], france_connect_authorization_id: france_connect_authorization_request_for_dgfip.latest_authorization.id, intitule: 'Demande de retraite progressive en ligne', applicant: demandeur })

    create_api_particulier_with_france_connect_embedded_fields

    create_fully_approved_api_impot_particulier_authorization_request
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def create_authorization_requests_for_dinum
    create_validated_authorization_request(:api_entreprise, attributes: { intitule: 'Démarches simplifiées', applicant: foreign_demandeur, contact_metier_email: demandeur.email })

    create_validated_authorization_request(:api_particulier, attributes: { intitule: 'Cantine à 1€', applicant: demandeur, scopes: AuthorizationDefinition.find('api_particulier').scopes.map(&:value).sample(3) + ['dgfip_annee_impot'] })

    create_dirty_from_v1_authorization_request
    create_authorization_request_with_contact_mention
    create_authorization_request_with_old_authorization
  end

  def create_dirty_from_v1_authorization_request
    authorization_request = create_reopened_authorization_request(:api_entreprise, attributes: { intitule: 'MPS 2014 - Migration v1', applicant: demandeur })
    authorization_request.update!(dirty_from_v1: true)
    authorization_request
  end

  def create_authorization_request_with_contact_mention
    create_draft_authorization_request(:api_entreprise, attributes: { intitule: 'Demande avec contact métier externe', applicant: another_demandeur, contact_metier_email: demandeur.email })
    create_validated_authorization_request(:api_entreprise, attributes: { intitule: 'Habilitation avec contact métier externe', applicant: another_demandeur, contact_metier_email: demandeur.email })
  end

  def create_authorization_request_with_old_authorization
    authorization_request = create_reopened_authorization_request(:api_entreprise, attributes: { intitule: 'Habilitation mise à jour', applicant: demandeur })
    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user: demandeur)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: api_entreprise_instructor)
    authorization_request
  end

  def demandeur
    @demandeur ||= User.create!(
      given_name: 'Jean',
      family_name: 'Dupont',
      email: 'user@yopmail.com',
      external_id: '1',
      job_title: 'Responsable des affaires générales',
      phone_number: '0123456789'
    )
  end

  def another_demandeur
    @another_demandeur ||= User.create!(
      given_name: 'Jacques',
      family_name: 'Dupont',
      email: 'whatever@fia1.fr',
      external_id: '10',
      job_title: 'Responsable des affaires juridiques',
      phone_number: '0823456789'
    )
  end

  def foreign_demandeur
    @foreign_demandeur ||= User.create!(
      given_name: 'Pierre',
      family_name: 'Dupont',
      email: 'user11@yopmail.com',
      external_id: '11',
      job_title: 'Responsable des affaires étrangères',
      phone_number: '0323456789'
    )
  end

  def api_entreprise_instructor
    @api_entreprise_instructor ||= User.create!(
      given_name: 'Paul',
      family_name: 'Dupont',
      email: 'api-entreprise@yopmail.com',
      external_id: '4',
      job_title: 'Responsable des instructions',
      phone_number: '0423456789',
      roles: ['api_entreprise:instructor', 'api_entreprise:developer']
    )
  end

  def api_entreprise_reporter
    @api_entreprise_reporter ||= User.create!(
      given_name: 'Marc',
      family_name: 'Dupont',
      email: 'user12@yopmail.com',
      external_id: '12',
      job_title: 'Responsable des reporteurs',
      phone_number: '0423456789',
      roles: ['api_entreprise:reporter']
    )
  end

  def data_pass_admin
    @data_pass_admin ||= User.create!(
      email: 'datapass@yopmail.com',
      roles: ['admin'] + all_authorization_definition_manager_roles + ['api_entreprise:developer', 'api_particulier:developer'],
    )
  end

  def dgfip_instructor_developer
    @dgfip_instructor_developer ||= User.create!(
      email: 'dgfip@yopmail.com',
      roles: all_dgfip_instructor_roles + all_dgfip_developer_roles
    )
  end

  def all_authorization_definition_manager_roles
    AuthorizationDefinition.all.map { |definition| "#{definition.id}:manager" }
  end

  def all_dgfip_authorizations_definitions
    AuthorizationDefinition
      .all
      .select { |definition| definition.provider&.id == 'dgfip' }
  end

  def all_dgfip_developer_roles
    all_dgfip_authorizations_definitions.map { |definition| "#{definition.id}:developer" }
  end

  def all_dgfip_instructor_roles
    all_dgfip_authorizations_definitions.map { |definition| "#{definition.id}:instructor" }
  end

  def clamart_organization
    @clamart_organization ||= create_organization(siret: '21920023500014', name: 'Ville de Clamart')
  end

  def dinum_organization
    @dinum_organization ||= create_organization(siret: '13002526500013', name: 'DINUM')
  end

  def create_organization(siret:, name:)
    Organization.create!(
      legal_entity_id: siret,
      last_mon_compte_pro_updated_at: DateTime.now,
      mon_compte_pro_payload: {
        label: name
      },
      insee_payload: JSON.parse(Rails.root.join('spec', 'fixtures', 'insee', "#{siret}.json").read),
      last_insee_payload_updated_at: DateTime.now,
    )
  end

  def create_draft_authorization_request(kind, attributes: {})
    create_authorization_request_model(
      kind,
      attributes: {
        fill_all_attributes: true,
        description: random_description,
      }.merge(attributes).compact
    )
  end

  def create_submitted_authorization_request(kind, attributes: {})
    user = extract_applicant(attributes)
    authorization_request = create_draft_authorization_request(kind, attributes:)

    organizer = SubmitAuthorizationRequest.call(authorization_request:, user:)

    raise "Fail to submit authorization request: #{organizer}" unless organizer.success?

    authorization_request
  end

  def create_validated_authorization_request(kind, attributes: {}, authorization_message: nil)
    authorization_request = create_submitted_authorization_request(kind, attributes:)

    organizer = ApproveAuthorizationRequest.call(
      authorization_request:,
      user: api_entreprise_instructor,
      authorization_message:
    )

    raise "Fail to approve authorization request #{organizer}" unless organizer.success?

    authorization_request
  end

  def create_revoked_authorization_request(kind, attributes: {})
    authorization_request = create_validated_authorization_request(kind, attributes:)

    organizer = RevokeAuthorizationRequest.call(authorization_request:, user: api_entreprise_instructor, revocation_of_authorization_params: { reason: 'Le cadre légal est maintenant caduque' })

    raise "Fail to revoked authorization request: #{organizer}" unless organizer.success?

    authorization_request
  end

  def create_refused_authorization_request(kind, attributes: {})
    authorization_request = create_submitted_authorization_request(kind, attributes:)
    denial_of_authorization_params = {
      reason: 'Cette demande ne correspond pas à nos critères',
    }.merge(attributes[:denial_of_authorization_params] || {})

    RefuseAuthorizationRequest.call(authorization_request:, user: api_entreprise_instructor, denial_of_authorization_params:).perform

    authorization_request
  end

  def create_request_changes_authorization_request(kind, attributes: {})
    authorization_request = create_submitted_authorization_request(kind, attributes:)
    instructor_modification_request_params = {
      reason: "Le cadre juridique n'est pas suffisamment précis, merci de le compléter",
    }.merge(attributes[:instructor_modification_request_params] || {})

    RequestChangesOnAuthorizationRequest.call(authorization_request:, user: api_entreprise_instructor, instructor_modification_request_params:).perform

    authorization_request
  end

  def create_reopened_authorization_request(kind, attributes: {})
    authorization_request = create_validated_authorization_request(kind, attributes:)

    ReopenAuthorization.call(authorization: authorization_request.latest_authorization, user: authorization_request.applicant).perform

    authorization_request
  end

  def create_authorization_request_model(kind, attributes: {})
    traits = [:draft]
    traits << kind

    applicant = extract_applicant(attributes)

    FactoryBot.create(
      :authorization_request,
      *traits,
      {
        applicant:,
        organization: applicant.current_organization,
      }.merge(attributes.except(:applicant))
    )
  end

  def create_instructor_draft_request(applicant:)
    FactoryBot.create(
      :instructor_draft_request,
      :with_applicant,
      :with_data,
      applicant:,
      instructor: api_entreprise_instructor,
      comment: "Comme discuté au téléphone, je vous envoie cette ébauche de demande d'habilitation.",
      public_id: '00000000-0000-0000-0000-000000000000',
      data: FactoryBot.build(:authorization_request, :api_entreprise, fill_all_attributes: true).data.merge('intitule' => 'Portail des aides publiques')
    )
  end

  def create_api_particulier_with_france_connect_embedded_fields
    authorization_request = FactoryBot.create(
      :authorization_request,
      :api_particulier,
      :with_france_connect_embedded_fields,
      fill_all_attributes: true,
      applicant: demandeur,
      organization: demandeur.current_organization,
      intitule: 'Portail famille avec FranceConnect unifié',
      description: random_description
    )

    SubmitAuthorizationRequest.call(authorization_request:, user: demandeur)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: api_entreprise_instructor)

    authorization_request
  end

  # rubocop:disable Metrics/AbcSize
  def create_fully_approved_api_impot_particulier_authorization_request
    authorization_request = create_validated_authorization_request(:api_impot_particulier_sandbox, attributes: { intitule: 'PASS FAMILLE', applicant: demandeur, created_at: 3.days.ago })

    StartNextAuthorizationRequestStage.call(authorization_request: authorization_request, user: authorization_request.applicant).perform

    authorization_request = AuthorizationRequest.find(authorization_request.id)

    valid_api_impot_particulier_production = FactoryBot.build(:authorization_request, :api_impot_particulier_production, fill_all_attributes: true)

    valid_api_impot_particulier_production.class.extra_attributes.each do |key|
      authorization_request.public_send(:"#{key}=", valid_api_impot_particulier_production.public_send(key))
    end
    authorization_request.safety_certification_document.attach([dummy_file])
    authorization_request.terms_of_service_accepted = true
    authorization_request.data_protection_officer_informed = true
    authorization_request.dpd_homologation_checkbox = '1'

    authorization_request.save!

    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user: authorization_request.applicant)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: api_entreprise_instructor)

    raise 'Authorization request not validated' unless authorization_request.reload.validated?
  end
  # rubocop:enable Metrics/AbcSize

  def extract_applicant(attributes)
    attributes[:applicant] || demandeur
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

  def create_oauth_app
    Doorkeeper::Application.create!(
      name: 'API Entreprise',
      uid: 'client_id',
      secret: 'so_secret',
      owner: api_entreprise_instructor,
    )
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
      user: api_entreprise_instructor,
      message_params:,
    )
    authorization_request.mark_messages_as_read_by_instructors!
  end

  def random_description
    [
      "Demande d'accès sécurisé aux données fiscales pour analyse économique.",
      "Requête d'habilitation pour accéder aux dossiers de santé publique.",
      "Solicitation d'accès aux registres d'état civil pour recherche démographique.",
      'Demande de permission pour consulter les données de permis de conduire pour étude de mobilité.',
      "Application pour accéder aux données cadastrales pour projet d'urbanisme.",
      "Requête pour l'utilisation des données de sécurité sociale dans le cadre d'une étude sur le vieillissement.",
      "Demande d'habilitation pour étudier les tendances de l'emploi avec accès aux données du ministère du Travail.",
      "Solicitation d'accès à la base de données électorales pour analyse politique.",
      "Demande d'autorisation pour utiliser les données de consommation énergétique pour recherche environnementale.",
      "Requête pour accéder aux archives judiciaires dans le but d'une étude sur la justice pénale."
    ].sample
  end

  def dummy_file
    {
      io: Rails.root.join('spec/fixtures/dummy.pdf').open,
      filename: 'dummy.pdf',
      content_type: 'application/pdf'
    }
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

  def production?
    Rails.env.production? && ENV['CAN_FLUSH_DB'].blank?
  end

  def create_message_templates
    Seeds::MessageTemplates.create
  end

  def create_stats_data
    Seeds::Stats.new(self).perform
  end
end
