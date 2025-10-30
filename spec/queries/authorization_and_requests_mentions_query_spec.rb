RSpec.describe AuthorizationAndRequestsMentionsQuery, type: :aquery do
  describe '#perform' do
    subject(:results) { described_class.new(user).perform(relation) }

    let(:user) { create(:user) }

    let!(:valid_authorization_request) { create(:authorization_request, :api_entreprise, contact_metier_email: user.email) }
    let!(:another_valid_authorization_request) { create(:authorization_request, :api_entreprise, responsable_traitement_email: user.email) }
    let!(:another_valid_authorization_request_with_uppercase_email) { create(:authorization_request, :api_entreprise) }
    let!(:invalid_authorization_request) { create(:authorization_request, :api_entreprise) }

    context 'with Authorization Requests' do
      let(:relation) { AuthorizationRequest.all }

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

    context 'with Authorizations' do
      let(:relation) { Authorization.all }

      let!(:valid_authorization) { create(:authorization, request: valid_authorization_request) }
      let!(:another_valid_authorization) { create(:authorization, request: another_valid_authorization_request) }
      let!(:invalid_authorization) { create(:authorization, request: invalid_authorization_request) }

      it 'returns an active record relation' do
        expect(results).to be_a(ActiveRecord::Relation)
      end

      it 'returns authorization where the user is mentioned' do
        expect(results).to include(valid_authorization, another_valid_authorization)
        expect(results).not_to include(invalid_authorization)
      end

      context 'when user is mentioned in authorization but is applicant of the request' do
        let!(:request_where_user_is_applicant) do
          create(:authorization_request, :api_entreprise, applicant: user, contact_metier_email: user.email)
        end
        let!(:authorization_where_user_is_applicant) { create(:authorization, request: request_where_user_is_applicant) }

        it 'excludes authorizations where user is the applicant of the request' do
          expect(results).to include(valid_authorization, another_valid_authorization)
          expect(results).not_to include(authorization_where_user_is_applicant, invalid_authorization)
        end
      end
    end
  end
end
