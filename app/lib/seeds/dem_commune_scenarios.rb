class Seeds::DemCommuneScenarios < Seeds
  EMAIL = 'dem-commune@yopmail.com'.freeze

  IDS = {
    'Brouillon' => 1,
    'Soumise' => 2,
    'Modifications demandées' => 3,
    'Validée' => 4,
    'Refusée' => 5,
    'Révoquée' => 6,
    'Archivée' => 7,
    'Réouverte' => 8,
    'Réouverte et soumise' => 9,
    'Migration v1' => 10,
    'Messages non lus' => 11,
    'Contact métier externe' => 12,
    'Pièce jointe' => 13,
    'Palier 2 en cours' => 14,
    'FranceConnect' => 15,
    'API Impôt particulier liée à FranceConnect' => 16,
  }.freeze

  def initialize(seeds)
    @seeds = seeds
  end

  def perform
    create_lifecycle_scenarios
    create_reopening_scenarios
    create_exchange_scenarios
    create_next_stage_scenario
    create_france_connect_scenario
    create_instructor_draft_scenario
    ActiveRecord::Base.connection.reset_pk_sequence!('authorization_requests')
  end

  private

  def create_lifecycle_scenarios
    @seeds.create_draft_authorization_request(:api_entreprise, attributes: scenario('Brouillon'))
    @seeds.create_submitted_authorization_request(:api_entreprise, attributes: scenario('Soumise'))
    @seeds.create_request_changes_authorization_request(:api_entreprise, attributes: scenario('Modifications demandées'))
    @seeds.create_validated_authorization_request(:api_entreprise, attributes: scenario('Validée'))
    @seeds.create_refused_authorization_request(:api_entreprise, attributes: scenario('Refusée'))
    @seeds.create_revoked_authorization_request(:api_entreprise, attributes: scenario('Révoquée'))
    create_archived_scenario
  end

  def create_archived_scenario
    authorization_request = @seeds.create_draft_authorization_request(:api_entreprise, attributes: scenario('Archivée'))

    ArchiveAuthorizationRequest.call(authorization_request:, user: applicant)
  end

  def create_reopening_scenarios
    @seeds.create_reopened_authorization_request(:api_entreprise, attributes: scenario('Réouverte'))
    @seeds.create_reopened_and_submitted_authorization_request(:api_entreprise, attributes: scenario('Réouverte et soumise'))
    create_migration_v1_scenario
  end

  def create_migration_v1_scenario
    authorization_request = @seeds.create_reopened_authorization_request(:api_entreprise, attributes: scenario('Migration v1'))
    authorization_request.update!(dirty_from_v1: true)
    authorization_request.authorizations.update_all(form_uid: nil) # rubocop:disable Rails/SkipsModelValidations
  end

  def create_exchange_scenarios
    create_unread_messages_scenario
    @seeds.create_validated_authorization_request(:api_entreprise, attributes: scenario('Contact métier externe').merge(contact_metier_email: 'dem-departement@yopmail.com'))
    create_attached_document_scenario
  end

  def create_unread_messages_scenario
    authorization_request = @seeds.create_submitted_authorization_request(:api_entreprise, attributes: scenario('Messages non lus'))

    SendMessageToInstructors.call(authorization_request:, user: applicant, message_params: { body: 'Bonjour, pouvez-vous me confirmer le périmètre des données ?' })
  end

  def create_attached_document_scenario
    authorization_request = @seeds.create_draft_authorization_request(:api_entreprise, attributes: scenario('Pièce jointe'))
    authorization_request.cadre_juridique_document.attach(io: Rails.root.join('spec/fixtures/dummy.pdf').open, filename: 'cadre-juridique.pdf', content_type: 'application/pdf')

    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user: applicant)
  end

  def create_next_stage_scenario
    authorization_request = @seeds.create_validated_authorization_request(:api_impot_particulier_sandbox, attributes: scenario('Palier 2 en cours'))

    StartNextAuthorizationRequestStage.call(authorization_request:, user: applicant)
  end

  def create_france_connect_scenario
    france_connect_request = @seeds.create_validated_authorization_request(:france_connect, attributes: scenario('FranceConnect'))

    @seeds.create_validated_authorization_request(
      :api_impot_particulier_sandbox,
      attributes: scenario('API Impôt particulier liée à FranceConnect').merge(modalities: ['with_france_connect'], france_connect_authorization_id: france_connect_request.latest_authorization.id)
    )
  end

  def create_instructor_draft_scenario
    FactoryBot.create(
      :instructor_draft_request,
      :with_applicant,
      :with_data,
      applicant:,
      instructor: User.find_by!(email: 'instructeur-apie@yopmail.com'),
      comment: 'Voici une ébauche de demande préparée pour votre commune.',
      data: FactoryBot.build(:authorization_request, :api_entreprise, fill_all_attributes: true).data.merge('intitule' => 'Référence — Brouillon d’instructeur')
    )
  end

  def scenario(name)
    { id: IDS.fetch(name), intitule: "Référence — #{name}", applicant: }
  end

  def applicant
    @applicant ||= User.find_by!(email: EMAIL)
  end
end
