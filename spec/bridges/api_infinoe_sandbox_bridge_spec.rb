RSpec.describe APIInfinoeSandboxBridge do
  describe '#perform' do
    subject(:bridge) { described_class.new(authorization_request).perform }

    let!(:authorization_request) { create(:authorization_request, :api_infinoe_sandbox, state: 'validated') }

    context 'when authorization request has no API Infinoe Production authorization request' do
      it 'creates a new one with valid applicant and organization' do
        expect {
          bridge
        }.to change(AuthorizationRequest, :count).by(1)

        latest_authorization_request = AuthorizationRequest.last

        expect(latest_authorization_request.applicant).to eq(authorization_request.applicant)
        expect(latest_authorization_request.organization).to eq(authorization_request.organization)
        expect(latest_authorization_request.sandbox_authorization_request).to eq(authorization_request)
      end
    end

    context 'when authorization_request is already linked to an API Infinoe Production authorization request' do
      before do
        create(:authorization_request, :api_infinoe_production, sandbox_authorization_request: authorization_request)
      end

      it 'does not create a new authorization request' do
        expect {
          bridge
        }.not_to change(AuthorizationRequest, :count)
      end
    end
  end
end
