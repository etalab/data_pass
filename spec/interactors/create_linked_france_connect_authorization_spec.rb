require 'rails_helper'

RSpec.describe CreateLinkedFranceConnectAuthorization do
  describe '#call' do
    subject(:interactor) { described_class.call(authorization_request:, authorization:) }

    context 'when apipfc_enabled is true' do
      let(:authorization_request) { create(:authorization_request, :api_particulier_entrouvert_publik, :with_france_connect_embedded_fields, fill_all_attributes: true) }
      let!(:authorization) { create(:authorization, request: authorization_request) }

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

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

      it 'stores the form_uid from the authorization request' do
        interactor
        fc_authorization = interactor.linked_france_connect_authorization

        expect(fc_authorization.form_uid).to eq(authorization_request.form_uid)
      end

      it 'sets france_connect_authorization_id on the authorization request' do
        interactor
        authorization_request.reload

        expect(authorization_request.france_connect_authorization_id).to eq(
          interactor.linked_france_connect_authorization.id.to_s
        )
      end

      it 'sets france_connect_authorization_id on the authorization data' do
        interactor
        authorization.reload

        expect(authorization.data['france_connect_authorization_id']).to eq(
          interactor.linked_france_connect_authorization.id.to_s
        )
      end
    end

    context 'when the authorization request is reopened and already has an FC authorization' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik,
          :reopened_and_submitted, :with_france_connect_embedded_fields,
          fill_all_attributes: true)
      end
      let!(:authorization) { create(:authorization, request: authorization_request) }
      let!(:existing_fc_authorization) do
        create(:authorization,
          request: authorization_request,
          authorization_request_class: 'AuthorizationRequest::FranceConnect')
      end

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        authorization_request.update_column(
          :data,
          authorization_request.data.merge('france_connect_authorization_id' => existing_fc_authorization.id.to_s)
        )
        authorization_request.reload
      end

      it { is_expected.to be_success }

      it 'does not create a FranceConnect authorization' do
        expect { interactor }.not_to change(Authorization, :count)
      end

      it 'does not set linked_france_connect_authorization in context' do
        expect(interactor.linked_france_connect_authorization).to be_nil
      end
    end

    context 'when the authorization request is reopened but has no FC authorization' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik,
          :reopened_and_submitted, :with_france_connect_embedded_fields,
          fill_all_attributes: true)
      end
      let!(:authorization) { create(:authorization, request: authorization_request) }

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      it { is_expected.to be_success }

      it 'creates a FranceConnect authorization' do
        expect { interactor }.to change(Authorization, :count).by(1)
      end

      it 'creates an authorization with FranceConnect authorization_request_class' do
        interactor
        fc_authorization = interactor.linked_france_connect_authorization

        expect(fc_authorization.authorization_request_class).to eq('AuthorizationRequest::FranceConnect')
      end
    end

    context 'when authorization request has a linked existing FC authorization (france_connect_authorization_id set)' do
      let(:authorization_request) do
        create(:authorization_request, :api_particulier_entrouvert_publik,
          :with_france_connect_embedded_fields, fill_all_attributes: true)
      end
      let!(:authorization) { create(:authorization, request: authorization_request) }

      around do |example|
        ServiceProvider.find('entrouvert').apipfc_enabled = true
        example.run
      ensure
        ServiceProvider.find('entrouvert').apipfc_enabled = false
      end

      before do
        fc_request = create(:authorization_request, :france_connect, organization: authorization_request.organization)
        fc_auth = create(:authorization, request: fc_request, authorization_request_class: 'AuthorizationRequest::FranceConnect')
        authorization_request.update_column(:data, authorization_request.data.merge('france_connect_authorization_id' => fc_auth.id.to_s))
        authorization_request.reload
      end

      it { is_expected.to be_success }

      it 'does not create a FranceConnect authorization' do
        expect { interactor }.not_to change(Authorization, :count)
      end

      it 'does not set linked_france_connect_authorization in context' do
        expect(interactor.linked_france_connect_authorization).to be_nil
      end
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

    context 'when apipfc_enabled is false' do
      let(:authorization_request) { create(:authorization_request, :api_particulier_entrouvert_publik, fill_all_attributes: true) }
      let!(:authorization) { create(:authorization, request: authorization_request) }

      it { is_expected.to be_success }

      it 'does not create a FranceConnect authorization' do
        expect { interactor }.not_to change(Authorization, :count)
      end
    end
  end
end
