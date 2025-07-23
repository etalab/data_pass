RSpec.describe DashboardFacade, type: :facade do
  let(:current_user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:search_query) { nil }
  let(:subdomain_types) { nil }
  let(:facade) { described_class.new(current_user, search_query, subdomain_types: subdomain_types) }

  before do
    current_user.organizations << organization
  end

  describe '#demandes_data' do
    subject(:data) { facade.demandes_data(policy_scope) }

    let(:policy_scope) { AuthorizationRequest.where(organization: organization) }

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

  describe '#habilitations_data' do
    subject(:data) { facade.habilitations_data(policy_scope) }

    let(:policy_scope) { Authorization.joins(:request).where(authorization_requests: { organization: organization }) }

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
