RSpec.describe AuthorizationRequestsSearchEngineBuilder do
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

    let!(:current_user_demande) { create(:authorization_request, :api_entreprise, applicant: current_user, organization:, state: 'submitted') }
    let!(:other_user_demande) { create(:authorization_request, :api_particulier, applicant: other_user, organization: organization, state: 'submitted') }
    let!(:base_items) { AuthorizationRequest.all }

    context 'without search parameters' do
      let(:params) { ActionController::Parameters.new({}) }

      it "returns all demandes with default sorting as user, mentions and organization's demandes" do
        expect(result).to contain_exactly(current_user_demande, other_user_demande)
        expect(service.search_engine.sorts.first.name).to eq('created_at')
        expect(service.search_engine.sorts.first.dir).to eq('desc')
      end
    end

    context 'when filtering demandes by user_relationship_eq' do
      let!(:current_user_request) { create(:authorization_request, :api_entreprise, applicant: current_user, organization:) }
      let!(:other_user_request) { create(:authorization_request, :api_particulier, applicant: other_user, organization:) }
      let!(:request_with_contact) do
        create(:authorization_request, :api_entreprise,
          applicant: other_user,
          organization: organization,
          data: { 'contact_metier_email' => current_user.email })
      end

      let!(:other_organization) { create(:organization, users: [other_user]) }
      let!(:request_from_other_organization) { create(:authorization_request, :api_particulier, applicant: other_user, organization: other_organization) }

      context 'when filtering by applicant' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'applicant' }
          )
        end

        it 'returns only demandes where current user is applicant' do
          expect(result).to include(current_user_request)
          expect(result).not_to include(other_user_request, request_with_contact, request_from_other_organization)
        end
      end

      context 'when filtering by organization' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'organization' }
          )
        end

        it 'returns only demandes from current user organization' do
          expect(result).to include(current_user_request, other_user_request, request_with_contact)
          expect(result).not_to include(request_from_other_organization)
        end
      end

      context 'when filtering by contact' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'contact' }
          )
        end

        it 'returns demandes where current user is contact' do
          expect(result).to include(request_with_contact)
          expect(result).not_to include(current_user_request, other_user_request, request_from_other_organization)
        end
      end
    end

    context 'when filtering demandes by text search' do
      let!(:request_with_intitule_cantine) do
        create(:authorization_request, :api_entreprise,
          applicant: current_user,
          organization: organization,
          data: { intitule: 'cantine' },
          id: 12)
      end

      let!(:request_with_intitule_transport) do
        create(:authorization_request, :api_particulier,
          applicant: current_user,
          organization: organization,
          data: { intitule: 'transport' },
          id: 34)
      end

      context 'when searching by authorization_request ID' do
        let(:search_text) { '12' }
        let(:params) do
          ActionController::Parameters.new(
            search_query: { within_data_or_id_cont: search_text }
          )
        end

        it 'returns demandes matching the ID' do
          expect(result).to contain_exactly(request_with_intitule_cantine)
        end
      end

      context 'when searching by intitulé cantine' do
        let(:search_text) { 'cantine' }
        let(:params) do
          ActionController::Parameters.new(
            search_query: { within_data_or_id_cont: search_text }
          )
        end

        it 'returns demandes matching the intitulé' do
          expect(result).to include(request_with_intitule_cantine)
          expect(result).not_to include(request_with_intitule_transport)
        end
      end

      context 'when searching by partial intitulé can' do
        let(:search_text) { 'can' }
        let(:params) do
          ActionController::Parameters.new(
            search_query: { within_data_or_id_cont: search_text }
          )
        end

        it 'returns demandes with partial intitulé match' do
          expect(result).to include(request_with_intitule_cantine)
          expect(result).not_to include(request_with_intitule_transport)
        end
      end
    end

    context 'when filtering demandes by state' do
      let!(:draft_request) { create(:authorization_request, :api_entreprise, state: 'draft', applicant: current_user, organization:) }
      let!(:submitted_request) { create(:authorization_request, :api_particulier, state: 'submitted', applicant: current_user, organization:) }
      let!(:refused_request) { create(:authorization_request, :api_particulier, state: 'refused', applicant: current_user, organization:) }

      context 'when filtering by draft' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { state_eq: 'draft' }
          )
        end

        it 'returns only draft demandes' do
          expect(result).to contain_exactly(draft_request)
        end
      end

      context 'when filtering by submitted' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { state_eq: 'submitted' }
          )
        end

        it 'returns only submitted demandes' do
          expect(result).to contain_exactly(submitted_request, current_user_demande, other_user_demande)
        end
      end

      context 'when filtering by refused' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { state_eq: 'refused' }
          )
        end

        it 'returns only refused demandes' do
          expect(result).to contain_exactly(refused_request)
        end
      end
    end
  end

  describe '#build_relation' do
    let(:policy_scope) { AuthorizationRequest.all }
    let(:params) { ActionController::Parameters.new({}) }

    it 'builds base authorization requests relation with proper includes and ordering' do
      expect(service).to receive(:build_search_engine).and_call_original

      result = service.build_relation(policy_scope)

      expect(result).to be_a(ActiveRecord::Relation)
      expect(service.search_engine).to be_present
    end

    context 'with subdomain_types specified' do
      let(:subdomain_types) { ['ApiEntrepriseRequest'] }

      it 'filters by subdomain types' do
        result = service.build_relation(policy_scope)

        expect(result).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe '#build_relation with multiple organizations' do
    subject(:result) { service.build_relation(policy_scope) }

    let(:user) { current_user }
    let(:user_organization) { create(:organization) }
    let(:other_organization) { create(:organization) }
    let(:another_user) { create(:user) }
    let(:params) { ActionController::Parameters.new({}) }

    let(:request_in_user_org) do
      create(:authorization_request, :api_entreprise, applicant: user, organization: user_organization)
    end
    let(:request_in_other_org_as_applicant) do
      create(:authorization_request, :api_particulier,
        applicant: user,
        organization: other_organization,
        data: { 'responsable_traitement_email' => user.email })
    end
    let(:request_in_other_org_as_contact) do
      create(:authorization_request, :api_entreprise,
        applicant: another_user,
        organization: other_organization,
        data: { 'contact_metier_email' => user.email })
    end

    before do
      user.add_to_organization(user_organization, verified: true, current: true)
      user.add_to_organization(other_organization, verified: true, current: false)
      another_user.add_to_organization(other_organization, verified: true, current: true)
    end

    context 'with a verified link between user and organization' do
      let(:policy_scope) { AuthorizationRequest.where(organization: user_organization) }

      it 'includes requests from user organization' do
        expect(result).to include(request_in_user_org)
      end

      it 'excludes requests from other organizations where user is applicant' do
        expect(result).not_to include(request_in_other_org_as_applicant)
      end

      it 'includes requests from other organizations where user is mentioned as contact' do
        expect(result).to include(request_in_other_org_as_contact)
      end
    end

    context 'with a unverified link between user and organization' do
      let(:policy_scope) { AuthorizationRequest.where(applicant: user, organization: user_organization) }

      before do
        allow(user).to receive_messages(current_organization_verified?: false, current_organization: user_organization)
      end

      it 'includes requests where user is applicant in their organization' do
        expect(result).to include(request_in_user_org)
      end

      it 'excludes requests from other organizations where user is applicant' do
        expect(result).not_to include(request_in_other_org_as_applicant)
      end

      it 'includes requests from other organizations where user is mentioned as contact' do
        expect(result).to include(request_in_other_org_as_contact)
      end

      context 'when filtering by organization' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'organization' }
          )
        end

        it 'returns empty relation' do
          expect(result).to be_empty
        end
      end
    end
  end
end
