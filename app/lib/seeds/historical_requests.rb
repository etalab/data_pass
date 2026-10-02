class Seeds::HistoricalRequests
  def initialize(context)
    @requests = context.requests
    @accounts = context.accounts
  end

  def perform
    @requests.create_validated_authorization_request(:api_entreprise, attributes: { intitule: 'Portail des appels d’offres', applicant: dem_historique, external_provider_id: 'e5b4c2d1-8f3a-4b6e-9c7d-1a2b3c4d5e6f' })
    create_requests_with_messages
    create_api_particulier_with_france_connect_embedded_fields
    create_fully_approved_api_impot_particulier_authorization_request
    create_authorization_request_with_old_authorization
  end

  private

  def create_requests_with_messages
    authorization_request = @requests.create_request_changes_authorization_request(:api_entreprise, attributes: { intitule: 'Portail des aides publiques', applicant: dem_multi_orga })
    send_message_to_instructors(authorization_request, body: 'Bonjour, je ne suis pas sûr du cadre légal de cette demande, pouvez-vous m\'aider ?')
    send_message_to_applicant(authorization_request, body: 'Bonjour, il faut que vous demandiez à votre DPO de vous fournir le document inférent à votre demande.')

    authorization_request = @requests.create_submitted_authorization_request(:api_entreprise, attributes: { intitule: 'Place des entreprises', applicant: dem_multi_orga })
    send_message_to_instructors(authorization_request, body: 'Je ne suis pas sûr du cadre de cette demande, pouvez-vous m’aider ?')
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
      description: @requests.random_description
    )

    SubmitAuthorizationRequest.call(authorization_request:, user: dem_historique)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: @requests.instructor_for(authorization_request))

    authorization_request
  end

  def create_fully_approved_api_impot_particulier_authorization_request
    authorization_request = @requests.create_validated_authorization_request(:api_impot_particulier_sandbox, attributes: { intitule: 'PASS FAMILLE', applicant: dem_historique, created_at: 3.days.ago })

    StartNextAuthorizationRequestStage.call(authorization_request: authorization_request, user: authorization_request.applicant).perform

    authorization_request = AuthorizationRequest.find(authorization_request.id)
    fill_production_stage(authorization_request)
    submit_and_approve_production_stage(authorization_request)
  end

  def fill_production_stage(authorization_request)
    valid_api_impot_particulier_production = FactoryBot.build(:authorization_request, :api_impot_particulier_production, applicant: authorization_request.applicant, organization: authorization_request.organization, fill_all_attributes: true)

    valid_api_impot_particulier_production.class.extra_attributes.each do |key|
      authorization_request.public_send(:"#{key}=", valid_api_impot_particulier_production.public_send(key))
    end
    authorization_request.safety_certification_document.attach([@requests.dummy_file])
    authorization_request.terms_of_service_accepted = true
    authorization_request.data_protection_officer_informed = true
    authorization_request.dpd_homologation_checkbox = '1'

    authorization_request.save!
  end

  def submit_and_approve_production_stage(authorization_request)
    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user: authorization_request.applicant)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: @requests.instructor_for(authorization_request))

    raise 'Authorization request not validated' unless authorization_request.reload.validated?
  end

  def create_authorization_request_with_old_authorization
    authorization_request = @requests.create_reopened_authorization_request(:api_entreprise, attributes: { intitule: 'Habilitation mise à jour', applicant: dem_historique })
    SubmitAuthorizationRequest.call(authorization_request: authorization_request.reload, user: dem_historique)
    ApproveAuthorizationRequest.call(authorization_request: authorization_request.reload, user: @requests.instructor_for(authorization_request))
    authorization_request
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
      user: @requests.instructor_for(authorization_request),
      message_params:,
    )
    authorization_request.mark_messages_as_read_by_instructors!
  end

  def dem_historique = @accounts.dem_historique

  def dem_multi_orga = @accounts.dem_multi_orga
end
