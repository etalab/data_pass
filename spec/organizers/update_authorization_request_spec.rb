RSpec.describe UpdateAuthorizationRequest, type: :organizer do
  describe '.call' do
    subject(:update_authorization_request) do
      described_class.call(
        authorization_request:,
        authorization_request_params:,
      )
    end

    let(:authorization_request) { create(:authorization_request, :hubee_cert_dc) }

    context 'with basic form and valid params' do
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          invalid: 'invalid',
          administrateur_metier_family_name: 'New Dupont',
        )
      end

      it { is_expected.to be_success }

      it 'updates authorization request' do
        expect {
          update_authorization_request
        }.to change { authorization_request.reload.administrateur_metier_family_name }.to('New Dupont')
      end
    end

    context 'with multi steps form' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise, fill_all_attributes: true) }
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          invalid: 'invalid',
          contact_metier_family_name:,
          current_build_step: 'contacts',
        )
      end

      context 'with valid attributes for the step' do
        let(:contact_metier_family_name) { 'New Dupont' }

        it { is_expected.to be_success }

        it 'updates authorization request' do
          expect {
            update_authorization_request
          }.to change { authorization_request.reload.contact_metier_family_name }.to('New Dupont')
        end
      end

      context 'with invalid attributes for the step' do
        let(:contact_metier_family_name) { '' }

        it { is_expected.to be_failure }

        it 'does not update authorization request' do
          expect {
            update_authorization_request
          }.not_to change { authorization_request.reload.contact_metier_family_name }
        end
      end
    end
  end
end
