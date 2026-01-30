require 'rails_helper'

RSpec.describe CreateLinkedFranceConnectAuthorization do
  describe '#call' do
    subject(:interactor) { described_class.call(authorization_request:, authorization:) }

    let(:authorization_request) { create(:authorization_request, :api_particulier, :with_france_connect_embedded_fields, fill_all_attributes: true) }
    let!(:authorization) { create(:authorization, request: authorization_request) }

    it { is_expected.to be_success }

    it 'creates a FranceConnect authorization' do
      expect { interactor }.to change(Authorization, :count).by(1)
    end

    it 'creates an authorization with FranceConnect authorization_request_class' do
      interactor
      fc_authorization = interactor.linked_france_connect_authorization

      expect(fc_authorization.authorization_request_class).to eq('AuthorizationRequest::FranceConnect')
    end

    it 'links the FC authorization to the parent authorization' do
      interactor
      fc_authorization = interactor.linked_france_connect_authorization

      expect(fc_authorization.parent_authorization).to eq(authorization)
    end

    it 'associates the FC authorization with the same request' do
      interactor
      fc_authorization = interactor.linked_france_connect_authorization

      expect(fc_authorization.request).to eq(authorization_request)
    end

    it 'copies FC data to the authorization' do
      interactor
      fc_authorization = interactor.linked_france_connect_authorization

      expect(fc_authorization.data['scopes']).to be_present
      expect(fc_authorization.data['cadre_juridique_nature']).to be_present
    end

    context 'when authorization request is not API Particulier' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise) }
      let!(:authorization) { create(:authorization, request: authorization_request) }

      it { is_expected.to be_success }

      it 'does not create a FranceConnect authorization' do
        expect { interactor }.not_to change(Authorization, :count)
      end

      it 'does not set linked_france_connect_authorization in context' do
        expect(interactor.linked_france_connect_authorization).to be_nil
      end
    end

    context 'when authorization request does not have FC embedded fields' do
      let(:authorization_request) { create(:authorization_request, :api_particulier, fill_all_attributes: true) }
      let!(:authorization) { create(:authorization, request: authorization_request) }

      it { is_expected.to be_success }

      it 'does not create a FranceConnect authorization' do
        expect { interactor }.not_to change(Authorization, :count)
      end
    end
  end
end
