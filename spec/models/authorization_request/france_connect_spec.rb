RSpec.describe AuthorizationRequest::FranceConnect do
  describe 'france_connected_authorizations association' do
    subject { france_connect_authorization_request.france_connected_authorizations }

    let(:organization) { create(:organization) }

    let(:france_connect_authorization_request) { create(:authorization_request, :france_connect, :validated, organization:) }
    let(:france_connect_authorization) { france_connect_authorization_request.authorizations.first }

    let(:france_connected_authorization_request_validated) { create(:authorization_request, :api_droits_cnam, :validated, france_connect_authorization:, organization:) }
    let!(:france_connected_authorization) { france_connected_authorization_request_validated.authorizations.first }

    let!(:another_france_connected_authorization_request) { create(:authorization_request, :france_connect, fill_all_attributes: true) }

    it 'returns associated france connected authorizations' do
      expect(subject).to contain_exactly(france_connected_authorization)
    end
  end
end
