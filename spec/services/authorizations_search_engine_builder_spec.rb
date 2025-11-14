RSpec.describe AuthorizationsSearchEngineBuilder do
  let(:service) { described_class.new(current_user, params.merge(subdomain_types: subdomain_types)) }
  let(:subdomain_types) { nil }
  let(:current_user) { create(:user) }
  let(:organization) { create(:organization, users: [current_user, other_user]) }
  let(:other_user) { create(:user) }

  before do
    current_user.add_to_organization(organization, verified: true, current: true)
  end

  describe '#build_search_engine' do
    subject(:result) { service.build_search_engine(base_items) }

    let!(:base_items) { Authorization.all }

    context 'when filtering authorizations by user_relationship_eq' do
      let!(:current_user_request) { create(:authorization_request, :api_entreprise, applicant: current_user, organization: organization, state: :validated) }
      let!(:current_user_authorization) { create(:authorization, request: current_user_request) }

      let!(:other_user_request) { create(:authorization_request, :api_particulier, applicant: other_user, organization: organization, state: :validated) }
      let!(:other_user_authorization) { create(:authorization, request: other_user_request) }

      let!(:request_with_contact) do
        create(:authorization_request, :api_entreprise,
          applicant: other_user,
          organization: organization,
          state: :validated,
          data: { 'contact_metier_email' => current_user.email })
      end
      let!(:authorization_with_contact) { create(:authorization, request: request_with_contact) }

      let!(:other_organization) { create(:organization, users: [other_user]) }
      let!(:request_from_other_organization) { create(:authorization_request, :api_particulier, applicant: other_user, organization: other_organization, state: :validated) }
      let!(:authorization_from_other_organization) { create(:authorization, request: request_from_other_organization) }

      context 'when filtering by applicant' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'applicant' }
          )
        end

        it 'returns only authorizations where current user is applicant' do
          expect(result).to include(current_user_authorization)
          expect(result).not_to include(other_user_authorization, authorization_with_contact, authorization_from_other_organization)
        end
      end

      context 'when filtering by organization' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'organization' }
          )
        end

        it 'returns only authorizations from current user organization' do
          expect(result).to include(current_user_authorization, other_user_authorization, authorization_with_contact)
          expect(result).not_to include(authorization_from_other_organization)
        end
      end

      context 'when filtering by contact' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'contact' }
          )
        end

        it 'returns authorizations where current user is contact' do
          expect(result).to include(authorization_with_contact)
          expect(result).not_to include(current_user_authorization, other_user_authorization, authorization_from_other_organization)
        end
      end
    end
  end

  describe '#build_relation' do
    let(:policy_scope) { Authorization.all }
    let(:params) { ActionController::Parameters.new({}) }

    it 'builds base authorizations relation with proper includes and ordering' do
      expect(service).to receive(:build_search_engine).and_call_original

      result = service.build_relation(policy_scope)

      expect(result).to be_a(ActiveRecord::Relation)
      expect(service.search_engine).to be_present
    end

    context 'with subdomain_types specified' do
      let(:subdomain_types) { ['AuthorizationRequest::ApiEntreprise'] }

      it 'filters by subdomain types' do
        result = service.build_relation(policy_scope)

        expect(result).to be_a(ActiveRecord::Relation)
      end
    end
  end
end
