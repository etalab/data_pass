RSpec.describe DemandesHabilitationsSearchEngineBuilder do
  let(:service) { described_class.new(current_user, params, subdomain_types: subdomain_types) }
  let(:subdomain_types) { nil }
  let(:current_user) { create(:user) }
  let(:organization) { create(:organization, users: [current_user, other_user]) }
  let(:other_user) { create(:user) }

  before do
    current_user.add_to_organization(organization, current: true)
  end

  describe '#build_search_engine' do
    subject(:result) { service.build_search_engine(base_items) }

    let!(:current_user_demande) { create(:authorization_request, :api_entreprise, applicant: current_user, organization:, state: 'submitted') }
    let!(:other_user_demande) { create(:authorization_request, :api_particulier, applicant: other_user, organization: organization, state: 'submitted') }
    let!(:base_items) { AuthorizationRequest.all }

    context 'without search parameters' do
      let(:params) { ActionController::Parameters.new({}) }

      it 'returns all demandes with default sorting' do
        expect(result).to contain_exactly(current_user_demande)
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
          expect(result).to contain_exactly(submitted_request, current_user_demande)
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

    context 'when filtering habilitations by user_relationship_eq' do
      let!(:other_organization) { create(:organization, users: [other_user]) }

      let!(:other_user_demande) do
        create(:authorization_request, :api_entreprise, applicant: other_user, organization: organization)
      end

      let!(:other_user_demande_with_contact) do
        create(:authorization_request, :api_particulier, applicant: other_user, organization: organization, data: { 'contact_metier_email' => current_user.email })
      end

      let!(:other_organization_demande) do
        create(:authorization_request, :api_particulier, applicant: other_user, organization: other_organization)
      end

      let!(:authorization_from_organization) { create(:authorization, applicant: other_user, request: other_user_demande) }
      let!(:authorization_with_contact) { create(:authorization, applicant: other_user, request: other_user_demande_with_contact) }
      let!(:authorization_from_other_organization) { create(:authorization, applicant: other_user, request: other_organization_demande) }

      let(:base_items) { Authorization.all }

      context 'when filtering by applicant' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'applicant' }
          )
        end

        it 'returns only habilitations where current user is applicant' do
          current_user_authorization_request = create(:authorization_request, :api_entreprise, applicant: current_user, organization: organization)
          current_user_authorization = create(:authorization, applicant: current_user, request: current_user_authorization_request)

          expect(result).to include(current_user_authorization)
          expect(result).not_to include(authorization_from_organization, authorization_with_contact, authorization_from_other_organization)
        end
      end

      context 'when filtering by contact' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'contact' }
          )
        end

        it 'returns only habilitations mentioning current user as contact' do
          expect(result).to include(authorization_with_contact)
          expect(result).not_to include(authorization_from_organization, authorization_from_other_organization)
        end
      end

      context 'when filtering by organization' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'organization' }
          )
        end

        it 'returns only habilitations from current user organization' do
          allow(current_user).to receive_messages(current_organization: organization, organizations: [organization])

          expect(result).to include(authorization_from_organization, authorization_with_contact)
          expect(result).not_to include(authorization_from_other_organization)
        end
      end
    end

    context 'when filtering habilitations by text search' do
      let!(:validated_cantine_request) { create(:authorization_request, :api_entreprise, state: 'validated', applicant: current_user, organization:, data: { intitule: 'cantine' }) }
      let!(:validated_transport_request) { create(:authorization_request, :api_particulier, state: 'validated', applicant: current_user, organization:, data: { intitule: 'transport' }) }

      let!(:habilitation_with_intitule_cantine) do
        create(:authorization,
          request: validated_cantine_request,
          state: 'active',
          id: 1)
      end

      let!(:habilitation_with_intitule_transport) do
        create(:authorization,
          request: validated_transport_request,
          state: 'active',
          id: 5)
      end

      let!(:base_items) { Authorization.all }

      context 'when searching by authorization ID' do
        let(:search_text) { '1' }
        let(:params) do
          ActionController::Parameters.new(
            search_query: { within_data_or_id_cont: search_text }
          )
        end

        it 'returns habilitations matching the ID' do
          expect(result).to contain_exactly(habilitation_with_intitule_cantine)
        end
      end

      context 'when searching by intitulé' do
        let(:search_text) { 'cantine' }
        let(:params) do
          ActionController::Parameters.new(
            search_query: { within_data_or_id_cont: search_text }
          )
        end

        it 'returns habilitations matching the intitulé' do
          expect(result).to contain_exactly(habilitation_with_intitule_cantine)
        end
      end

      context 'when searching by partial intitulé' do
        let(:search_text) { 'can' }
        let(:params) do
          ActionController::Parameters.new(
            search_query: { within_data_or_id_cont: search_text }
          )
        end

        it 'returns habilitations with partial intitulé match' do
          expect(result).to contain_exactly(habilitation_with_intitule_cantine)
        end
      end
    end

    context 'when filtering habilitations by state' do
      let!(:validated_request) { create(:authorization_request, :api_entreprise, state: 'validated', applicant: current_user, organization:) }
      let!(:other_validated_request) { create(:authorization_request, :api_particulier, state: 'validated', applicant: current_user, organization:) }
      let!(:active_authorization) { create(:authorization, request: validated_request, state: 'active', organization:) }
      let!(:revoked_authorization) { create(:authorization, request: other_validated_request, state: 'revoked', organization:) }
      let!(:obsolete_authorization) { create(:authorization, request: validated_request, state: 'obsolete', organization:) }
      let(:base_items) { Authorization.all }

      context 'when filtering by active state' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { state_eq: 'active' }
          )
        end

        it 'returns only active habilitations' do
          expect(result).to contain_exactly(active_authorization)
        end
      end

      context 'when filtering by revoked state' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { state_eq: 'revoked' }
          )
        end

        it 'returns only revoked habilitations' do
          expect(result).to contain_exactly(revoked_authorization)
        end
      end

      context 'when filtering by obsolete state' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { state_eq: 'obsolete' }
          )
        end

        it 'returns only obsolete habilitations' do
          expect(result).to contain_exactly(obsolete_authorization)
        end
      end
    end
  end

  describe '#build_authorization_requests_relation' do
    let(:policy_scope) { AuthorizationRequest.all }
    let(:params) { ActionController::Parameters.new({}) }

    it 'builds base authorization requests relation with proper includes and ordering' do
      expect(service).to receive(:build_search_engine).and_call_original

      result = service.build_authorization_requests_relation(policy_scope)

      expect(result).to be_a(ActiveRecord::Relation)
      expect(service.search_engine).to be_present
    end

    context 'with subdomain_types specified' do
      let(:subdomain_types) { ['ApiEntrepriseRequest'] }

      it 'filters by subdomain types' do
        result = service.build_authorization_requests_relation(policy_scope)

        expect(result).to be_a(ActiveRecord::Relation)
      end
    end
  end

  describe '#build_authorizations_relation' do
    let(:policy_scope) { Authorization.all }
    let(:params) { ActionController::Parameters.new({}) }

    it 'builds base authorizations relation with proper includes and ordering' do
      expect(service).to receive(:build_search_engine).and_call_original

      result = service.build_authorizations_relation(policy_scope)

      expect(result).to be_a(ActiveRecord::Relation)
      expect(service.search_engine).to be_present
    end
  end
end
