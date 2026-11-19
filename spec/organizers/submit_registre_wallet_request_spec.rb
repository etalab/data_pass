RSpec.describe SubmitAuthorizationRequest, '.call' do
  context 'with a wallet registry request' do
    subject(:submit_request) { described_class.call(user: applicant, authorization_request:) }

    let(:organization) { create(:organization) }
    let(:applicant) { create(:user).tap { |user| user.add_to_organization(organization, current: true) } }
    let(:authorization_request) { create(:authorization_request, :registre_wallet, :draft, fill_all_attributes: true, organization:, applicant:) }

    context 'with a complete request' do
      it { is_expected.to be_success }

      it 'sends the request to verification' do
        expect { submit_request }.to change { authorization_request.reload.state }.from('draft').to('submitted')
      end

      it 'records the submission in the history' do
        expect { submit_request }.to change { AuthorizationRequestEvent.where(name: 'submit', authorization_request:).count }.by(1)
      end
    end

    context 'when another request of the SIREN was submitted with the same service identifier in the meantime' do
      before do
        authorization_request
        other_applicant = create(:user).tap { |user| user.add_to_organization(organization, current: true) }
        create(:authorization_request, :registre_wallet, :submitted, organization:, applicant: other_applicant, wallet_service_identifier: authorization_request.wallet_service_identifier)
      end

      it { is_expected.to be_failure }

      it 'keeps the request as a draft' do
        expect { submit_request }.not_to change { authorization_request.reload.state }.from('draft')
      end

      it 'names the identifier to change' do
        expect(submit_request.authorization_request.errors.attribute_names).to include(:wallet_service_identifier)
      end
    end
  end
end
