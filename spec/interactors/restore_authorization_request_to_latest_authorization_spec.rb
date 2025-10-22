RSpec.describe RestoreAuthorizationRequestToLatestAuthorization, type: :interactor do
  describe '#call' do
    subject(:restore) { described_class.call(authorization_request:) }

    let(:authorization_request) { create(:authorization_request, :api_sfip_sandbox, :validated) }
    let(:authorization) { authorization_request.latest_authorization }

    before do
      authorization_request.update!(scopes: %w[dgfip_aft dgfip_rfr dgfip_nbpart dgfip_annee_n_moins_1])
    end

    context 'when authorization data has scopes as JSON string' do
      before do
        authorization.data['scopes'] = '["dgfip_aft", "dgfip_rfr", "dgfip_annee_n_moins_1"]'
        authorization.save!
      end

      it 'restores scopes from authorization data' do
        expect { restore }.to change { authorization_request.reload.scopes }.to(%w[dgfip_aft dgfip_annee_n_moins_1 dgfip_rfr])
      end
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

    context 'when authorization data has invalid JSON string' do
      before do
        authorization.data['scopes'] = 'invalid json'
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
  end
end
