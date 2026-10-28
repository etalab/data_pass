RSpec.describe EnsureAuthorizationRequestCreatedByAPI do
  subject(:result) { described_class.call(authorization_request:) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft) }

  context 'when the request was created by API' do
    before { create(:authorization_request_event, :create_by_api, authorization_request:) }

    it { is_expected.to be_a_success }
  end

  context 'when the request was started in the portal' do
    before { create(:authorization_request_event, :create, authorization_request:) }

    it 'fails with not_created_by_api' do
      expect(result).to be_a_failure
      expect(result.error[:key]).to eq(:not_created_by_api)
    end
  end

  context 'when the request only has events written by API' do
    before { create(:authorization_request_event, :update_by_api, authorization_request:) }

    it 'fails with not_created_by_api' do
      expect(result.error[:key]).to eq(:not_created_by_api)
    end
  end
end
