RSpec.describe DashboardDemandesFacade, type: :facade do
  let(:organization) { create(:organization) }
  let(:current_user) do
    user = create(:user)
    user.add_to_organization(organization, verified: true, current: true)
    user
  end
  let(:search_query) { nil }
  let(:subdomain_types) { nil }
  let(:scoped_relation) { AuthorizationRequest.where(organization: organization) }

  let(:facade) do
    described_class.new(
      user: current_user,
      search_query: search_query,
      subdomain_types: subdomain_types,
      scoped_relation: scoped_relation
    )
  end

  describe '#data' do
    subject(:data) { facade.data }

    context 'when authorization_requests exist' do
      let!(:draft_request) { create(:authorization_request, :api_entreprise, organization:, applicant: current_user, state: :draft) }
      let!(:submitted_request) { create(:authorization_request, :api_entreprise, organization:, applicant: current_user, state: :submitted) }
      let!(:changes_requested_request) { create(:authorization_request, :api_particulier, organization:, applicant: current_user, state: :changes_requested) }
      let!(:refused_request) { create(:authorization_request, :api_particulier, organization:, applicant: current_user, state: :refused) }
      let!(:archived_request) { create(:authorization_request, :api_particulier, organization:, applicant: current_user, state: :archived) }

      it 'returns authorization_requests in correct categories' do
        expect(data[:highlighted_categories][:changes_requested]).to include(changes_requested_request)
        expect(data[:categories][:pending]).to include(submitted_request)
        expect(data[:categories][:draft]).to include(draft_request)
        expect(data[:categories][:refused]).to include(refused_request)
      end

      it 'excludes archived requests' do
        all_requests = data[:highlighted_categories].values.flatten +
                       data[:categories].values.flatten

        expect(all_requests).not_to include(archived_request)
      end

      it 'includes search engine in response' do
        expect(data[:search_engine]).to be_present
      end
    end

    context 'when no authorization_requests exist' do
      it 'returns empty categories' do
        expect(data[:highlighted_categories][:changes_requested]).to be_empty
        expect(data[:categories][:pending]).to be_empty
        expect(data[:categories][:draft]).to be_empty
        expect(data[:categories][:refused]).to be_empty
      end
    end
  end
end
