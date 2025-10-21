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
end
