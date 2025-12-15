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

  describe 'service integration' do
    it 'uses AuthorizationRequestsSearchEngineBuilder' do
      builder = facade.send(:search_builder)
      expect(builder).to be_a(AuthorizationRequestsSearchEngineBuilder)
    end

    it 'passes subdomain_types to the builder' do
      facade_with_subdomain = described_class.new(
        user: current_user,
        search_query: search_query,
        subdomain_types: ['ApiEntrepriseRequest'],
        scoped_relation: scoped_relation
      )

      builder = facade_with_subdomain.send(:search_builder)
      expect(builder.subdomain_types).to eq(['ApiEntrepriseRequest'])
    end
  end

  describe '#show_filters?' do
    subject(:show_filters) { facade.show_filters? }

    context 'when there are 9 or fewer authorization requests' do
      it 'returns false' do
        9.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :draft) }

        expect(show_filters).to be false
      end
    end

    context 'when there are more than 9 authorization requests' do
      it 'returns true' do
        10.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :draft) }

        expect(show_filters).to be true
      end
    end

    context 'when counting includes mentions from other organizations' do
      let(:other_organization) { create(:organization) }
      let(:other_user) { create(:user) }

      before do
        other_user.add_to_organization(other_organization, verified: true, current: true)
      end

      it 'includes mentions in the count' do
        8.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :draft) }
        2.times { create(:authorization_request, :api_entreprise, organization: other_organization, applicant: other_user, state: :draft, contact_metier_email: current_user.email) }

        expect(show_filters).to be true
      end
    end

    context 'when filtering by displayed states' do
      it 'only counts requests in displayed states' do
        5.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :draft) }
        5.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :submitted) }
        5.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :validated) }

        expect(show_filters).to be true
      end
    end
  end

  describe 'default filter behavior' do
    let(:other_user) do
      user = create(:user)
      user.add_to_organization(organization, verified: true)
      user
    end

    context 'when user has 10+ requests' do
      before do
        8.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :draft) }
        3.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: other_user, state: :draft) }
      end

      it 'applies applicant filter by default' do
        expect(facade.search_query).to eq({ user_relationship_eq: 'applicant' })
      end

      it 'only shows current user requests' do
        data = facade.data
        all_requests = data[:categories][:draft]

        expect(all_requests.count).to eq(8)
        expect(all_requests.map(&:applicant)).to all(eq(current_user))
      end
    end

    context 'when user has 9 or fewer requests' do
      before do
        5.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :draft) }
        3.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: other_user, state: :draft) }
      end

      it 'does not apply default filter' do
        expect(facade.search_query).to be_nil
      end

      it 'shows all organization requests' do
        data = facade.data
        all_requests = data[:categories][:draft]

        expect(all_requests.count).to eq(8)
      end
    end

    context 'when explicit filter is provided' do
      let(:search_query) { { user_relationship_eq: 'organization' } }

      before do
        8.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: current_user, state: :draft) }
        3.times { create(:authorization_request, :api_entreprise, organization: organization, applicant: other_user, state: :draft) }
      end

      it 'respects the explicit filter' do
        expect(facade.search_query).to eq({ user_relationship_eq: 'organization' })
      end

      it 'shows all organization requests' do
        data = facade.data
        all_requests = data[:categories][:draft]

        expect(all_requests.count).to eq(11)
      end
    end
  end
end
