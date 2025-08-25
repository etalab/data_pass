require 'rails_helper'

RSpec.describe TransitionAuthorizationRequestToStageOfAuthorization, type: :interactor do
  describe '#call' do
    subject(:interactor) { described_class.call(authorization_request:, authorization:) }

    context 'with api_impot_particulier when there is a previous_stage' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :validated) }
      let(:authorization) { create(:authorization, request: authorization_request, state: 'active') }
      let(:previous_stage_form_uid) { 'api-impot-particulier-sandbox' }

      before do
        authorization.update!(authorization_request_class: 'AuthorizationRequest::APIImpotParticulierSandbox')
        authorization_request.update!(form_uid: 'api-impot-particulier-production')
      end

      it 'successfully transitions to the sandbox stage' do
        interactor

        expect(interactor.success?).to be true
        reloaded = AuthorizationRequest.find(authorization_request.id)
        expect(reloaded.type).to eq('AuthorizationRequest::APIImpotParticulierSandbox')
      end

      it 'updates the form_uid to the previous stage form uid' do
        interactor

        reloaded = AuthorizationRequest.find(authorization_request.id)
        expect(reloaded.form_uid).to eq(previous_stage_form_uid)
      end
    end

    context 'with api_particulier when there is no previous_stage' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise_editeur, :validated) }
      let(:authorization) { create(:authorization, request: authorization_request, state: 'active') }

      before do
        authorization.update!(authorization_request_class: 'AuthorizationRequest::APIParticulier')
      end

      it 'fails when trying to find a non-existent previous stage' do
        expect { interactor }.to raise_error(ActiveRecord::RecordNotFound,
          'No previous stage configured for AuthorizationRequest::APIEntreprise')
      end
    end

    context 'when authorization is not reopenable' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :validated, created_at: 2.days.ago) }
      let(:authorization) { create(:authorization, request: authorization_request, state: 'active', created_at: 1.day.ago) }

      before do
        create(:authorization,
          request: authorization_request,
          state: 'active',
          authorization_request_class: authorization.authorization_request_class,
          created_at: 1.hour.ago)
      end

      it 'fails the context' do
        expect(interactor.failure?).to be true
      end
    end

    context 'when authorization_request type matches authorization class' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier, :validated) }
      let(:authorization) { create(:authorization, request: authorization_request, state: 'active') }

      before do
        authorization.update!(authorization_request_class: authorization_request.type)
      end

      it 'does not update the authorization_request' do
        expect { interactor }.not_to change { authorization_request.reload.updated_at }
      end
    end
  end
end
