RSpec.describe RestoreAuthorizationRequestToLatestAuthorization, type: :interactor do
  describe '#call' do
    subject(:restore) { described_class.call(authorization_request:) }

    let(:authorization_request) { create(:authorization_request, :api_sfip_sandbox, :validated) }
    let(:authorization) { authorization_request.latest_authorization }

    before do
      authorization_request.update!(scopes: %w[dgfip_aft dgfip_rfr dgfip_nbpart dgfip_annee_n_moins_1])
    end

    context 'when authorization data has scopes as array' do
      before do
        authorization.data['scopes'] = %w[dgfip_aft dgfip_rfr dgfip_annee_n_moins_1]
        authorization.save!
      end

      it 'restores scopes from authorization data' do
        expect { restore }.to change { authorization_request.reload.scopes }.to(%w[dgfip_aft dgfip_annee_n_moins_1 dgfip_rfr])
      end
    end

    context 'when authorization data has empty array scopes' do
      before do
        authorization.data['scopes'] = []
        authorization.save!
      end

      it 'sets scopes to empty array' do
        expect { restore }.to change { authorization_request.reload.scopes }.to([])
      end
    end

    context 'when authorization data has nil scopes' do
      before do
        authorization.data['scopes'] = nil
        authorization.save!
      end

      it 'sets scopes to empty array' do
        expect { restore }.to change { authorization_request.reload.scopes }.to([])
      end
    end

    context 'when a sandbox authorization was validated more recently than the production one' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_stationnement_residentiel_production, :validated) }

      before do
        authorization_request.authorizations.create!(
          applicant: authorization_request.applicant,
          authorization_request_class: 'AuthorizationRequest::APISFiPSandbox',
          form_uid: 'api-sfip-stationnement-residentiel-sandbox',
          data: authorization_request.data,
          created_at: 1.day.from_now,
        )
      end

      it 'restores to the most recently validated authorization (the sandbox)' do
        restore

        expect(AuthorizationRequest.find(authorization_request.id).type).to eq('AuthorizationRequest::APISFiPSandbox')
      end

      it 'aligns the form_uid with the restored sandbox stage so type and form_uid stay coherent' do
        restore

        restored = AuthorizationRequest.find(authorization_request.id)
        expect(restored.form_uid).to eq('api-sfip-stationnement-residentiel-sandbox')
        expect(restored.form.authorization_request_class.to_s).to eq(restored.type)
      end
    end

    context 'when an older production authorization exists but the sandbox was validated more recently' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_stationnement_residentiel_sandbox, :validated) }

      before do
        authorization_request.authorizations.create!(
          applicant: authorization_request.applicant,
          authorization_request_class: 'AuthorizationRequest::APISFiP',
          form_uid: 'api-sfip-stationnement-residentiel-production',
          data: authorization_request.data,
          created_at: 1.day.ago,
        )
      end

      it 'restores to the most recently validated authorization (the sandbox), not the most advanced stage' do
        restore

        expect(AuthorizationRequest.find(authorization_request.id).type).to eq('AuthorizationRequest::APISFiPSandbox')
      end

      it 'keeps type and form_uid coherent on the sandbox stage' do
        restore

        restored = AuthorizationRequest.find(authorization_request.id)
        expect(restored.form_uid).to eq('api-sfip-stationnement-residentiel-sandbox')
        expect(restored.form.authorization_request_class.to_s).to eq(restored.type)
      end
    end
  end
end
