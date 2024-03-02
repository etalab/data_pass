class Seeds
  def perform
    create_entities
    create_all_verified_emails

    create_authorization_requests_for_clamart
    create_authorization_requests_for_dinum
  end

  def flushdb
    raise 'Not in production!' if production?

    ActiveRecord::Base.connection.tables.each do |table|
      # rubocop:disable Performance/CollectionLiteralInLoop
      next if %w[schema_migrations ar_internal_metadata].include?(table)
      # rubocop:enable Performance/CollectionLiteralInLoop

      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
    end
  end

  private

  def create_entities
    clamart_organization.users << demandeur
    clamart_organization.users << another_demandeur

    dinum_organization.users << api_entreprise_instructor
    dinum_organization.users << foreign_demandeur
  end

  def create_authorization_requests_for_clamart
    create_validated_authorization_request(:api_entreprise, attributes: { intitule: "Portail des appels d'offres", applicant: demandeur })
    create_request_changes_authorization_request(:api_entreprise, attributes: { intitule: 'Portail des aides publiques', applicant: another_demandeur })
    create_refused_authorization_request(:api_entreprise, attributes: { intitule: 'Statistiques sur les effectifs', applicant: demandeur })
    create_reopened_authorization_request(:api_entreprise_mgdis, attributes: { applicant: demandeur })

    create_submitted_authorization_request(:api_entreprise, attributes: { intitule: 'Place des entreprises', applicant: another_demandeur })
  end

  def create_authorization_requests_for_dinum
    create_validated_authorization_request(:api_entreprise, attributes: { intitule: 'Démarches simplifiées', applicant: foreign_demandeur, contact_metier_email: demandeur.email })
  end

  def demandeur
    @demandeur ||= User.create!(
      given_name: 'Jean',
      family_name: 'Dupont',
      email: 'user@yopmail.com',
      external_id: '1',
      current_organization: clamart_organization,
    )
  end

  def another_demandeur
    @another_demandeur ||= User.create!(
      given_name: 'Jacques',
      family_name: 'Dupont',
      email: 'user10@yopmail.com',
      external_id: '10',
      current_organization: clamart_organization,
    )
  end

  def foreign_demandeur
    @foreign_demandeur ||= User.create!(
      given_name: 'Pierre',
      family_name: 'Dupont',
      email: 'user11@yopmail.com',
      external_id: '11',
      current_organization: dinum_organization,
    )
  end

  def api_entreprise_instructor
    @api_entreprise_instructor ||= User.create!(
      given_name: 'Paul',
      family_name: 'Dupont',
      email: 'api-entreprise@yopmail.com',
      external_id: '4',
      current_organization: dinum_organization,
      roles: ['api_entreprise:instructor']
    )
  end

  def clamart_organization
    @clamart_organization ||= create_organization(siret: '21920023500014', name: 'Ville de Clamart')
  end

  def dinum_organization
    @dinum_organization ||= create_organization(siret: '13001518800019', name: 'DINUM')
  end

  def create_organization(siret:, name:)
    Organization.create!(
      siret:,
      last_mon_compte_pro_updated_at: DateTime.now,
      mon_compte_pro_payload: {
        label: name
      }
    )
  end

  def create_draft_authorization_request(kind, attributes: {})
    create_authorization_request_model(
      kind,
      attributes: attributes.merge(
        fill_all_attributes: true,
        description: random_description,
      )
    )
  end

  def create_submitted_authorization_request(kind, attributes: {})
    user = extract_applicant(attributes)
    authorization_request = create_draft_authorization_request(kind, attributes:)

    SubmitAuthorizationRequest.call(authorization_request:, user:).perform

    authorization_request
  end

  def create_validated_authorization_request(kind, attributes: {})
    authorization_request = create_submitted_authorization_request(kind, attributes:)

    ApproveAuthorizationRequest.call(authorization_request:, user: api_entreprise_instructor).perform

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

  def extract_applicant(attributes)
    attributes[:applicant] || demandeur
  end

  def create_all_verified_emails
    User.find_each do |user|
      create_verified_email(user.email)
    end

    AuthorizationRequest.find_each do |authorization_request|
      authorization_request.class.contact_types.each do |contact_type|
        create_verified_email(authorization_request.send(:"#{contact_type}_email"))
      end
    end
  end

  def create_verified_email(email)
    return if email.blank?
    return if VerifiedEmail.exists?(email:)

    VerifiedEmail.create!(
      email:,
      status: 'deliverable',
      verified_at: Time.zone.now,
    )
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

  def load_all_models!
    Dir[Rails.root.join('app/models/**/*.rb')].each { |f| require f }
  end

  def production?
    Rails.env.production? && ENV['CAN_FLUSH_DB'].blank?
  end
end
