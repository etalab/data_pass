RSpec.describe 'Admin operations on legacy requests', type: :acceptance do
  describe 'transfer on validated request with legacy invalid data' do
    let(:organization) { create(:organization) }
    let(:applicant) { create(:user, current_organization: organization) }
    let(:user) { create(:user) }

    context 'when legacy request has nil intitule' do
      let(:new_applicant) { create(:user, current_organization: organization) }
      let!(:authorization_request) do
        create(:authorization_request, :api_entreprise, :validated,
          applicant:,
          organization:)
      end

      before do
        authorization_request.intitule = nil
        authorization_request.save(validate: false)
      end

      it 'request would be invalid if submitted again' do
        expect(authorization_request.reload.valid?(:submit)).to be(false)
      end

      it 'allows transfer despite invalid data' do
        result = TransferAuthorizationRequestToNewApplicant.call(
          authorization_request: authorization_request.reload,
          new_applicant_email: new_applicant.email,
          user:
        )

        expect(result).to be_success
        expect(authorization_request.reload.applicant).to eq(new_applicant)
      end
    end

    context 'when new applicant does not belong to organization' do
      let(:new_applicant) { create(:user) }
      let!(:authorization_request) do
        create(:authorization_request, :api_entreprise, :validated,
          applicant:,
          organization:)
      end

      before do
        authorization_request.intitule = nil
        authorization_request.save(validate: false)
      end

      it 'does not allow transfer' do
        result = TransferAuthorizationRequestToNewApplicant.call(
          authorization_request: authorization_request.reload,
          new_applicant_email: new_applicant.email,
          user:
        )

        expect(result).to be_failure
      end
    end
  end
end
