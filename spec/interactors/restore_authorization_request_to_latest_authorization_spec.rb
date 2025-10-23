RSpec.describe RestoreAuthorizationRequestToLatestAuthorization, type: :interactor do
  describe '#call' do
    subject(:restore) { described_class.call(authorization_request:) }

    let(:authorization) { authorization_request.latest_authorization }

    context 'with scopes attribute' do
      let(:authorization_request) { create(:authorization_request, :api_sfip_sandbox, :validated) }

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

    context 'with modalities attribute' do
      let(:authorization_request) { create(:authorization_request, :api_ficoba_sandbox, :validated) }

      before do
        authorization_request.update!(modalities: %w[with_ficoba_iban with_ficoba_spi])
      end

      context 'when authorization data has modalities as JSON string' do
        before do
          authorization.data['modalities'] = '["with_ficoba_iban"]'
          authorization.save!
        end

        it 'restores modalities from authorization data' do
          expect { restore }.to change { authorization_request.reload.modalities }.to(%w[with_ficoba_iban])
        end
      end

      context 'when authorization data has modalities as array' do
        before do
          authorization.data['modalities'] = %w[with_ficoba_iban]
          authorization.save!
        end

        it 'restores modalities from authorization data' do
          expect { restore }.to change { authorization_request.reload.modalities }.to(%w[with_ficoba_iban])
        end
      end

      context 'when authorization data has nil modalities' do
        before do
          authorization.data['modalities'] = nil
          authorization.save!
        end

        it 'sets modalities to empty array' do
          expect { restore }.to change { authorization_request.reload.modalities }.to([])
        end
      end
    end
  end
end
