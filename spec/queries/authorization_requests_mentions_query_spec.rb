RSpec.describe AuthorizationRequestsMentionsQuery, type: :query do
  describe '#perform' do
    subject(:results) { described_class.new(user).perform(relation) }

    let(:user) { create(:user) }
    let(:relation) { AuthorizationRequest.all }

    let!(:valid_authorization_request) { create(:authorization_request, :api_entreprise, contact_metier_email: user.email) }
    let!(:another_valid_authorization_request) { create(:authorization_request, :api_entreprise, responsable_traitement_email: user.email) }
    let!(:another_valid_authorization_request_with_uppercase_email) { create(:authorization_request, :api_entreprise) }
    let!(:invalid_authorization_request) { create(:authorization_request, :api_entreprise) }

    before do
      another_valid_authorization_request_with_uppercase_email.data['contact_metier_email'] = user.email.upcase
      another_valid_authorization_request_with_uppercase_email.save!
    end

    it 'returns an active record relation' do
      expect(results).to be_a(ActiveRecord::Relation)
    end

    it 'returns the authorization requests where the user is mentioned' do
      expect(results).to contain_exactly(valid_authorization_request, another_valid_authorization_request, another_valid_authorization_request_with_uppercase_email)
    end

    context 'when user is both mentioned and applicant' do
      let!(:request_where_user_is_applicant_and_contact) do
        create(:authorization_request, :api_entreprise, applicant: user, contact_metier_email: user.email)
      end

      it 'excludes requests where user is the applicant' do
        expect(results).to contain_exactly(valid_authorization_request, another_valid_authorization_request, another_valid_authorization_request_with_uppercase_email)
        expect(results).not_to include(request_where_user_is_applicant_and_contact)
      end
    end
  end
end
