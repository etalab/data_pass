class Seeds
  # rubocop:disable Metrics/AbcSize
  def perform
    create_entities

    create_authorization_request(:api_entreprise)
    create_authorization_request(:api_entreprise, :submitted, attributes: { intitule: 'Marché publics', description: very_long_description, applicant: another_demandeur })
    create_authorization_request(:api_entreprise_mgdis, :validated)

    reopened_authorization_request = create_authorization_request(:api_entreprise, :validated, attributes: { intitule: 'Marché publics - Ville de Bordeaux', description: 'reopening' })
    ReopenAuthorization.call(authorization: reopened_authorization_request.latest_authorization, user: reopened_authorization_request.applicant).perform

    create_authorization_request(:api_entreprise, :validated, attributes: { intitule: 'Marché publics', contact_technique_email: demandeur.email, applicant: foreign_demandeur })
    create_authorization_request(:api_particulier, :refused, attributes: { intitule: 'Vente de données personnelles', applicant: another_demandeur })
    create_authorization_request(:api_particulier, :changes_requested, attributes: { intitule: 'Tarification cantine' })
    create_authorization_request(:portail_hubee_demarche_certdc)

    create_authorization_request(:api_infinoe_production, :draft)
    create_authorization_request(:api_service_national_inscription_concours_examen, :changes_requested, attributes: {
      intitule: 'Inscription à un concours ou un examen (hors permis de conduire)',
      description: very_long_description
    })
    create_authorization_request(:api_service_national, :submitted)
  end
  # rubocop:enable Metrics/AbcSize

  def flushdb
    raise 'Not in production!' if production?

    ActiveRecord::Base.connection.tables.each do |table|
      next if table == 'schema_migrations'

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

  def demandeur
    @demandeur ||= User.create!(
      email: 'user@yopmail.com',
      external_id: '1',
      current_organization: clamart_organization,
    )
  end

  def another_demandeur
    @another_demandeur ||= User.create!(
      email: 'user10@yopmail.com',
      external_id: '10',
      current_organization: clamart_organization,
    )
  end

  def foreign_demandeur
    @foreign_demandeur ||= User.create!(
      email: 'user11@yopmail.com',
      external_id: '11',
      current_organization: dinum_organization,
    )
  end

  def api_entreprise_instructor
    @api_entreprise_instructor ||= User.create!(
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

  def create_authorization_request(kind, status = :draft, attributes: {}, traits: [])
    traits << kind
    traits << status

    applicant = attributes.delete(:applicant) || demandeur

    authorization_request = FactoryBot.create(
      :authorization_request,
      *traits,
      {
        applicant:,
        organization: applicant.current_organization,
      }.merge(attributes)
    )

    create_events_for(authorization_request, status)

    authorization_request
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_events_for(authorization_request, status)
    case status
    when :draft
      create_event(authorization_request, :create, created_at: 1.day.ago)
    when :submitted
      create_event(authorization_request, :create, created_at: 3.hours.ago)
      create_event(authorization_request, :submit, created_at: 1.hour.ago)
    when :refused
      create_event(authorization_request, :create, created_at: 3.hours.ago)
      create_event(authorization_request, :submit, created_at: 1.hour.ago)
      create_event(authorization_request, :refuse, created_at: 30.minutes.ago)
    when :changes_requested
      create_event(authorization_request, :create, created_at: 3.hours.ago)
      create_event(authorization_request, :submit, created_at: 1.hour.ago)
      create_event(authorization_request, :request_changes, created_at: 30.minutes.ago)
    when :validated
      create_event(authorization_request, :create, created_at: 3.hours.ago)
      create_event(authorization_request, :submit, created_at: 1.hour.ago)
      create_event(authorization_request, :approve, created_at: 30.minutes.ago)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def create_event(authorization_request, status, attributes = {})
    attributes[:user] = if %i[create submit].include?(status)
                          authorization_request.applicant
                        else
                          api_entreprise_instructor
                        end

    FactoryBot.create(
      :authorization_request_event,
      status,
      attributes.merge(authorization_request:)
    )
  end

  def very_long_description
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl. Donec euismod, nisl eget aliquam ultricies, nunc nisl aliquet nunc, vitae aliquam nisl nisl vitae nisl.'
  end

  def load_all_models!
    Dir[Rails.root.join('app/models/**/*.rb')].each { |f| require f }
  end

  def production?
    Rails.env.production? && ENV['CAN_FLUSH_DB'].blank?
  end
end
