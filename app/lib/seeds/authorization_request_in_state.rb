class Seeds::AuthorizationRequestInState
  INSTRUCTORS_BY_PRIORITY = %w[
    instructeur-apie@yopmail.com
    instructeur-dgfip@yopmail.com
    instructeur-multi-fd@yopmail.com
    manager-fd-dgfip@yopmail.com
    admin-instructeur@yopmail.com
  ].freeze

  DESCRIPTIONS = [
    'Demande d’accès sécurisé aux données fiscales pour analyse économique.',
    'Requête d’habilitation pour accéder aux dossiers de santé publique.',
    'Solicitation d’accès aux registres d’état civil pour recherche démographique.',
    'Demande de permission pour consulter les données de permis de conduire pour étude de mobilité.',
    'Application pour accéder aux données cadastrales pour projet d’urbanisme.',
    'Requête pour l’utilisation des données de sécurité sociale dans le cadre d’une étude sur le vieillissement.',
    'Demande d’habilitation pour étudier les tendances de l’emploi avec accès aux données du ministère du Travail.',
    'Solicitation d’accès à la base de données électorales pour analyse politique.',
    'Demande d’autorisation pour utiliser les données de consommation énergétique pour recherche environnementale.',
    'Requête pour accéder aux archives judiciaires dans le but d’une étude sur la justice pénale.'
  ].freeze

  def initialize(accounts)
    @accounts = accounts
  end

  def create_draft_authorization_request(kind, attributes: {})
    description = attributes.fetch(:description) { random_description }
    authorization_request = create_authorization_request_model(kind, attributes: { fill_all_attributes: true }.merge(attributes.except(:description)))

    authorization_request.update!(description:) if description && authorization_request.respond_to?(:description=)
    authorization_request
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
      user: instructor_for(authorization_request),
      authorization_message:
    )

    raise "Fail to approve authorization request #{organizer}" unless organizer.success?

    authorization_request
  end

  def create_revoked_authorization_request(kind, attributes: {})
    authorization_request = create_validated_authorization_request(kind, attributes:)

    organizer = RevokeAuthorizationRequest.call(authorization_request:, user: instructor_for(authorization_request), revocation_of_authorization_params: { reason: 'Le cadre légal est maintenant caduque' })

    raise "Fail to revoked authorization request: #{organizer}" unless organizer.success?

    authorization_request
  end

  def create_refused_authorization_request(kind, attributes: {})
    authorization_request = create_submitted_authorization_request(kind, attributes:)
    denial_of_authorization_params = {
      reason: 'Cette demande ne correspond pas à nos critères',
    }.merge(attributes[:denial_of_authorization_params] || {})

    RefuseAuthorizationRequest.call(authorization_request:, user: instructor_for(authorization_request), denial_of_authorization_params:).perform

    authorization_request
  end

  def create_request_changes_authorization_request(kind, attributes: {})
    authorization_request = create_submitted_authorization_request(kind, attributes:)
    instructor_modification_request_params = {
      reason: 'Le cadre juridique n’est pas suffisamment précis, merci de le compléter',
    }.merge(attributes[:instructor_modification_request_params] || {})

    RequestChangesOnAuthorizationRequest.call(authorization_request:, user: instructor_for(authorization_request), instructor_modification_request_params:).perform

    authorization_request
  end

  def create_reopened_authorization_request(kind, attributes: {})
    authorization_request = create_validated_authorization_request(kind, attributes:)

    ReopenAuthorization.call(authorization: authorization_request.latest_authorization, user: authorization_request.applicant).perform

    authorization_request
  end

  def create_reopened_and_submitted_authorization_request(kind, attributes: {})
    user = extract_applicant(attributes)
    authorization_request = create_reopened_authorization_request(kind, attributes:)

    organizer = SubmitAuthorizationRequest.call(authorization_request:, user:)

    raise "Fail to submit authorization request: #{organizer}" unless organizer.success?

    authorization_request
  end

  def instructor_for(authorization_request)
    instructed_type = authorization_request.type.underscore.split('/').last

    instructors.find { |instructor| instructor.instructor?(instructed_type) } ||
      raise("Aucun instructeur seedé pour le type #{instructed_type}")
  end

  def random_description
    DESCRIPTIONS.sample
  end

  def dummy_file
    {
      io: Rails.root.join('spec/fixtures/dummy.pdf').open,
      filename: 'dummy.pdf',
      content_type: 'application/pdf'
    }
  end

  private

  def create_authorization_request_model(kind, attributes: {})
    applicant = extract_applicant(attributes)

    FactoryBot.create(
      :authorization_request,
      :draft,
      kind,
      {
        applicant:,
        organization: applicant.current_organization,
      }.merge(attributes.except(:applicant))
    )
  end

  def extract_applicant(attributes)
    attributes[:applicant] || @accounts.dem_commune
  end

  def instructors
    @instructors ||= INSTRUCTORS_BY_PRIORITY.map { |email| User.find_by!(email:) }
  end
end
