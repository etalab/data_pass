RSpec.describe 'Late failure of a transactional organizer', type: :organizer do
  around do |example|
    previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = GoodJob::Adapter.new(execution_mode: :external)
    example.run
  ensure
    ActiveJob::Base.queue_adapter = previous_adapter
  end

  shared_examples 'a transactional organizer' do |last_step, enqueues_jobs_on_success: true|
    if enqueues_jobs_on_success
      it 'enqueues jobs when it succeeds' do
        expect { organizer }.to change(GoodJob::Job, :count)
      end
    end

    LateFailureHelpers::FAILURE_MODES.each do |failure, mode|
      context "when #{last_step} runs then fails with #{failure}" do
        before { make_step_fail_after_running(last_step, mode) }

        it 'enqueues no job nor email, and keeps no event' do
          expect { call_through_late_failure { organizer } }.to not_change(GoodJob::Job, :count)
            .and not_change(AuthorizationRequestEvent, :count)
        end
      end
    end
  end

  let(:instructor) { create(:user, :instructor, authorization_request_types: [authorization_request_kind.to_s]) }
  let(:authorization_request_kind) { :api_entreprise }

  before do
    create(:webhook, :validated, :enabled, authorization_definition_id: authorization_request_kind.to_s, events: Webhook::VALID_EVENTS)
  end

  describe Admin::CreateAdminChange do
    subject(:organizer) { described_class.call(user: create(:user, :admin), authorization_request:, public_reason: 'Correction') { |ar| ar.update!(data: ar.data.merge('intitule' => 'Nouveau titre')) } }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise) }

    it_behaves_like 'a transactional organizer', CreateAuthorizationRequestEventModel, enqueues_jobs_on_success: false
  end

  describe ApproveAuthorizationRequest do
    subject(:organizer) { described_class.call(authorization_request:, user: instructor) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    it_behaves_like 'a transactional organizer', ExecuteAuthorizationRequestBridge
  end

  describe ArchiveAuthorizationRequest do
    subject(:organizer) { described_class.call(authorization_request:, user: authorization_request.applicant) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

    it_behaves_like 'a transactional organizer', DeliverAuthorizationRequestNotification
  end

  describe CancelAuthorizationReopening do
    subject(:organizer) { described_class.call(authorization_request:, user: instructor, authorization_request_reopening_cancellation_params: { reason: 'Trop ancien' }) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :reopened) }

    it_behaves_like 'a transactional organizer', RestoreAuthorizationRequestToLatestAuthorization
  end

  describe CancelNextAuthorizationRequestStage do
    subject(:organizer) { described_class.call(authorization_request:, user: authorization_request.applicant) }

    let(:authorization_request_kind) { :api_impot_particulier }
    let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_stationnement_residentiel_production, :draft) }

    it_behaves_like 'a transactional organizer', RestoreAuthorizationRequestToAuthorization, enqueues_jobs_on_success: false
  end

  describe ClaimInstructorDraftRequest do
    subject(:organizer) { described_class.call(instructor_draft_request: create(:instructor_draft_request, :complete, claimed: false)) }

    it_behaves_like 'a transactional organizer', MarkInstructorDraftAsClaimed, enqueues_jobs_on_success: false
  end

  describe CreateAuthorizationRequestFromAPI do
    subject(:organizer) do
      described_class.call(
        form_uid: 'api-entreprise',
        authorized_types: %w[AuthorizationRequest::APIEntreprise],
        authorization_request_params: ActionController::Parameters.new(intitule: 'Mon projet'),
        applicant_params: { email: 'applicant@example.com' },
        siret: '13002526500013',
        user: oauth_user,
      )
    end

    let!(:oauth_user) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }

    before { mock_insee_sirene_api_etablissement_valid(siret: '13002526500013') }

    it_behaves_like 'a transactional organizer', DeliverAuthorizationRequestNotification
  end

  describe RefuseAuthorizationRequest do
    subject(:organizer) { described_class.call(denial_of_authorization_params: attributes_for(:denial_of_authorization), authorization_request:, user: instructor) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    it_behaves_like 'a transactional organizer', RestoreAuthorizationRequestToLatestAuthorization
  end

  describe ReopenAuthorization do
    subject(:organizer) { described_class.call(authorization: authorization_request.latest_authorization, user: authorization_request.applicant) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it_behaves_like 'a transactional organizer', DeliverAuthorizationRequestNotification
  end

  describe RequestChangesOnAuthorizationRequest do
    subject(:organizer) { described_class.call(instructor_modification_request_params: attributes_for(:instructor_modification_request), authorization_request:, user: instructor) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

    it_behaves_like 'a transactional organizer', DeliverAuthorizationRequestNotification
  end

  describe RevokeAuthorization do
    subject(:organizer) { described_class.call(authorization: authorization_request.latest_authorization, revocation_of_authorization_params: attributes_for(:revocation_of_authorization), user: instructor) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it_behaves_like 'a transactional organizer', RevokeChildAuthorizations
  end

  describe RevokeAuthorizationRequest do
    subject(:organizer) { described_class.call(authorization_request:, revocation_of_authorization_params: attributes_for(:revocation_of_authorization), user: instructor) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it_behaves_like 'a transactional organizer', ExecuteAuthorizationRequestBridge
  end

  describe SendMessageToApplicant do
    subject(:organizer) { described_class.call(authorization_request:, user: instructor, message_params: attributes_for(:message)) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise) }

    it_behaves_like 'a transactional organizer', IncrementAuthorizationRequestUnreadCounter

    it 'leaves the unread counter untouched on a late failure' do
      authorization_request.redis_unread_messages_from_instructors.reset
      make_step_fail_after_running(IncrementAuthorizationRequestUnreadCounter, :fail)

      expect { organizer }.not_to change(authorization_request.redis_unread_messages_from_instructors, :value)
    end
  end

  describe SendMessageToInstructors do
    subject(:organizer) { described_class.call(authorization_request:, user: authorization_request.applicant, message_params: attributes_for(:message)) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise) }

    before { instructor }

    it_behaves_like 'a transactional organizer', IncrementAuthorizationRequestUnreadCounter
  end

  describe StartNextAuthorizationRequestStage do
    subject(:organizer) { described_class.call(authorization_request:, user: authorization_request.applicant) }

    let(:authorization_request_kind) { :api_impot_particulier }
    let!(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :validated) }

    it_behaves_like 'a transactional organizer', AssignLatestProductionDataInAuthorizationRequest, enqueues_jobs_on_success: false
  end

  describe SubmitAuthorizationRequest do
    subject(:organizer) { described_class.call(user: authorization_request.applicant, authorization_request:) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, fill_all_attributes: true) }

    before { instructor }

    it_behaves_like 'a transactional organizer', RunMalwareScanOnDocuments
  end

  describe TransferAuthorizationRequestToNewApplicant do
    subject(:organizer) { described_class.call(authorization_request:, new_applicant_email: new_applicant.email, user: instructor) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:new_applicant) { create(:user, current_organization: authorization_request.organization) }

    it_behaves_like 'a transactional organizer', DeliverAuthorizationRequestNotification
  end

  describe TransferAuthorizationRequestToNewOrganization do
    subject(:organizer) { described_class.call(authorization_request:, new_organization:, new_applicant: create(:user, current_organization: new_organization), user: instructor) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:new_organization) { create(:organization) }

    it_behaves_like 'a transactional organizer', DeliverAuthorizationRequestNotification
  end

  describe UpdateAuthorizationRequest do
    subject(:organizer) { described_class.call(authorization_request:, authorization_request_params: ActionController::Parameters.new(intitule: 'Nouveau titre'), user: authorization_request.applicant) }

    let!(:authorization_request) { create(:authorization_request, :api_entreprise) }

    it_behaves_like 'a transactional organizer', DeliverAuthorizationRequestNotification
  end
end
