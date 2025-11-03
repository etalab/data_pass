RSpec.describe DashboardHabilitationsFacade, type: :facade do
  let(:organization) { create(:organization) }
  let(:current_user) do
    user = create(:user)
    user.add_to_organization(organization, verified: true, current: true)
    user
  end
  let(:search_query) { nil }
  let(:subdomain_types) { nil }
  let(:scoped_relation) do
    Authorization
      .joins(:request)
      .where(authorization_requests: { organization: organization })
  end

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

    context 'when authorizations exist' do
      let!(:authorization_request) { create(:authorization_request, organization: organization, applicant: current_user, state: :validated) }
      let!(:active_authorization) { create(:authorization, request: authorization_request, state: :active) }
      let!(:revoked_authorization) { create(:authorization, request: authorization_request, state: :revoked) }

      it 'returns authorizations in correct categories' do
        expect(data[:categories][:active]).to include(active_authorization)
        expect(data[:categories][:revoked]).to include(revoked_authorization)
      end

      it 'has empty highlighted_categories' do
        expect(data[:highlighted_categories]).to be_empty
      end

      it 'includes search engine in response' do
        expect(data[:search_engine]).to be_present
      end
    end

    context 'when no authorizations exist' do
      it 'returns empty categories' do
        expect(data[:categories][:active]).to be_empty
        expect(data[:categories][:revoked]).to be_empty
      end
    end
  end

  describe 'service integration' do
    it 'uses AuthorizationsSearchEngineBuilder' do
      builder = facade.send(:search_builder)
      expect(builder).to be_a(AuthorizationsSearchEngineBuilder)
    end

    it 'passes subdomain_types to the builder' do
      facade_with_subdomain = described_class.new(
        user: current_user,
        search_query: search_query,
        subdomain_types: ['AuthorizationRequest::ApiEntreprise'],
        scoped_relation: scoped_relation
      )

      builder = facade_with_subdomain.send(:search_builder)
      expect(builder.subdomain_types).to eq(['AuthorizationRequest::ApiEntreprise'])
    end
  end

  describe '#show_filters?' do
    subject(:show_filters) { facade.show_filters? }

    context 'when there are 9 or fewer authorizations' do
      it 'returns false' do
        authorization_request = create(:authorization_request, organization: organization, applicant: current_user, state: :validated)
        create_list(:authorization, 9, request: authorization_request, state: :active)

        expect(show_filters).to be false
      end
    end

    context 'when there are more than 9 authorizations' do
      it 'returns true' do
        authorization_request = create(:authorization_request, organization: organization, applicant: current_user, state: :validated)
        create_list(:authorization, 10, request: authorization_request, state: :active)

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
        authorization_request = create(:authorization_request, organization: organization, applicant: current_user, state: :validated)
        create_list(:authorization, 8, request: authorization_request, state: :active)

        mentioned_request = create(:authorization_request, :api_entreprise, organization: other_organization, applicant: other_user, state: :validated, contact_metier_email: current_user.email)
        create_list(:authorization, 2, request: mentioned_request, state: :active)

        expect(show_filters).to be true
      end
    end

    context 'when filtering by displayed states' do
      it 'only counts authorizations in displayed states' do
        authorization_request = create(:authorization_request, organization: organization, applicant: current_user, state: :validated)
        create_list(:authorization, 10, request: authorization_request, state: :active)

        expect(show_filters).to be true
      end
    end
  end
end
