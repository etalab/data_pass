RSpec.describe AuthorizationRequestsMentionsQuery, type: :aquery do
  describe '#perform' do
    subject(:authorization_requests) { described_class.new(user).perform }

    let(:user) { create(:user) }

    let!(:valid_authorization_request) { create(:authorization_request, :api_entreprise, contact_metier_email: user.email) }
    let!(:another_valid_authorization_request) { create(:authorization_request, :api_entreprise, responsable_traitement_email: user.email) }
    let!(:invalid_authorization_request) { create(:authorization_request, :api_entreprise) }

    it 'returns an active record relation' do
      expect(authorization_requests).to be_a(ActiveRecord::Relation)
    end

    it 'returns the authorization requests where the user is mentioned' do
      expect(authorization_requests).to contain_exactly(valid_authorization_request, another_valid_authorization_request)
    end
  end
end
