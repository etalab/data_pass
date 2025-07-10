RSpec.describe SearchEngineBuilder do
  let(:service) { described_class.new(current_user, params) }
  let(:current_user) { create(:user) }
  let(:organization) { create(:organization, users: [current_user]) }
  let(:other_user) { create(:user) }

  describe '#build_search_engine' do
    let!(:current_user_demande) { create(:authorization_request, :api_entreprise, applicant: current_user, organization:) }
    let!(:other_user_demande) { create(:authorization_request, :api_particulier, applicant: other_user) }
    let(:base_items) { AuthorizationRequest.all }

    context 'without search parameters' do
      let(:params) { ActionController::Parameters.new({}) }

      it 'returns all demandes with default sorting' do
        result = service.build_search_engine(base_items)

        expect(result).to contain_exactly(current_user_demande, other_user_demande)
        expect(service.search_engine.sorts.first.name).to eq('created_at')
        expect(service.search_engine.sorts.first.dir).to eq('desc')
      end
    end

    context 'with user_relationship_eq filter' do
      context 'when filtering by applicant' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'applicant' }
          )
        end

        it 'returns only demande where current user is applicant' do
          result = service.build_search_engine(base_items)
          expect(result).to contain_exactly(current_user_demande)
        end
      end

      context 'when filtering by organization' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'organization' }
          )
        end

        it 'returns only demandes where current user is not applicant' do
          result = service.build_search_engine(base_items)
          expect(result).to contain_exactly(other_user_demande)
        end
      end

      context 'when filtering by contact in demandes' do
        let(:params) do
          ActionController::Parameters.new(
            search_query: { user_relationship_eq: 'contact' }
          )
        end

        it 'returns demandes where current_user is contact' do
          allow(AuthorizationRequestsMentionsQuery).to receive(:new)
            .with(current_user)
            .and_return(instance_double(AuthorizationRequestsMentionsQuery, perform: base_items.where.not(applicant: current_user)))

          result = service.build_search_engine(base_items)
          expect(result).to contain_exactly(other_user_demande)
        end
      end
    end

    context 'with authorization request name as text search' do
      let(:search_text) { current_user_demande.name }
      let(:params) do
        ActionController::Parameters.new(
          search_query: { within_data_or_api_service_name_or_id_cont: search_text }
        )
      end

      it 'applies authorization_request name as search filter' do
        allow(base_items).to receive(:search_by_query).with(search_text)
          .and_return(base_items.where(id: current_user_demande.id))

        result = service.build_search_engine(base_items)
        expect(result).to contain_exactly(current_user_demande)
      end
    end

    context 'with ransack parameters' do
      let(:params) do
        ActionController::Parameters.new(
          search_query: {
            state_eq: 'draft',
            user_relationship_eq: 'applicant'
          }
        )
      end

      it 'filters with ransack, ignoring user_relationship_eq' do
        expect(base_items).to receive(:ransack) { |args|
          expect(args['state_eq']).to eq('draft')
          expect(args).not_to have_key('user_relationship_eq')
        }.and_return(instance_double(Ransack::Search,
          sorts: [], 'sorts=': nil, result: base_items.none))
        service.build_search_engine(base_items)
      end
    end

    context 'with contact filter in habilitations' do
      let!(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: other_user) }
      let!(:authorization_with_contact) do
        authorization = create(:authorization,
          applicant: other_user,
          request: authorization_request)

        authorization.update!(
          data: authorization.data.merge('contact_metier_email' => current_user.email)
        )
        authorization
      end

      let!(:authorization_without_contact) do
        create(:authorization,
          applicant: other_user,
          request: authorization_request)
      end

      let(:base_items) { Authorization.all }
      let(:params) do
        ActionController::Parameters.new(
          search_query: { user_relationship_eq: 'contact' }
        )
      end

      it 'returns only habilitation mentioning current user as contact' do
        result = service.build_search_engine(base_items)
        expect(result).to include(authorization_with_contact)
        expect(result).not_to include(authorization_without_contact)
      end
    end
  end
end
