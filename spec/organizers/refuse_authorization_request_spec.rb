RSpec.describe RefuseAuthorizationRequest do
  describe '.call' do
    subject(:refuse_authorization_request) { described_class.call(denial_of_authorization_params:, authorization_request:) }

    context 'with valid params' do
      let(:denial_of_authorization_params) { attributes_for(:denial_of_authorization) }

      context 'with authorization request in submitted state' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

        it { is_expected.to be_success }

        it 'creates a denial authorization' do
          expect { refuse_authorization_request }.to change(DenialOfAuthorization, :count).by(1)
        end

        it 'affects authorization request to context' do
          expect(refuse_authorization_request.authorization_request).to eq(authorization_request)
        end

        it 'changes state to refused' do
          expect { refuse_authorization_request }.to change { authorization_request.reload.state }.from('submitted').to('refused')
        end

        it 'delivers an email' do
          expect { refuse_authorization_request }.to have_enqueued_mail(AuthorizationRequestMailer, :refused)
        end
      end

      context 'with authorization request in draft state' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

        it { is_expected.to be_failure }

        it 'does not change state' do
          expect { refuse_authorization_request }.not_to change { authorization_request.reload.state }
        end
      end
    end

    context 'with invalid params' do
      let(:denial_of_authorization_params) { attributes_for(:denial_of_authorization, reason: nil) }
      let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted) }

      it { is_expected.to be_failure }

      it 'does not create a denial authorization' do
        expect { refuse_authorization_request }.not_to change(DenialOfAuthorization, :count)
      end

      it 'does not change state' do
        expect { refuse_authorization_request }.not_to change { authorization_request.reload.state }
      end
    end
  end
end
