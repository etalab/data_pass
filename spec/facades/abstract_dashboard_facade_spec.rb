RSpec.describe AbstractDashboardFacade, type: :facade do
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

  let(:concrete_facade) do
    Class.new(AbstractDashboardFacade) do
      def data
        {
          highlighted_categories: {},
          categories: {},
          search_engine: search_builder.search_engine
        }
      end

      def model_class
        Authorization
      end

      def displayed_states
        %i[active revoked]
      end
    end
  end

  let(:facade) do
    concrete_facade.new(
      user: current_user,
      search_query: search_query,
      subdomain_types: subdomain_types,
      scoped_relation: scoped_relation
    )
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
  end

  describe '#show_organization_verification_warning?' do
    subject(:show_warning) { facade.show_organization_verification_warning? }

    context 'when user organization is verified' do
      it 'returns false' do
        expect(show_warning).to be false
      end
    end

    context 'when user organization is not verified' do
      let(:current_user) do
        user = create(:user)
        user.add_to_organization(organization, verified: false, current: true)
        user
      end

      context 'with no user_relationship filter' do
        it 'returns true' do
          expect(show_warning).to be true
        end
      end

      context 'with user_relationship_eq=organization filter' do
        let(:search_query) { { user_relationship_eq: 'organization' } }

        it 'returns true' do
          expect(show_warning).to be true
        end
      end

      context 'with user_relationship_eq=mentions filter' do
        let(:search_query) { { user_relationship_eq: 'mentions' } }

        it 'returns false' do
          expect(show_warning).to be false
        end
      end
    end
  end

  describe '#user_relationship_options' do
    subject(:options) { facade.user_relationship_options }

    context 'when user organization is verified' do
      it 'includes all three options' do
        expect(options.size).to eq(3)
        expect(options.map(&:last)).to contain_exactly('applicant', 'contact', 'organization')
      end

      it 'includes organization option' do
        organization_option = options.find { |opt| opt.last == 'organization' }
        expect(organization_option).to be_present
      end
    end

    context 'when user organization is not verified' do
      let(:current_user) do
        user = create(:user)
        user.add_to_organization(organization, verified: false, current: true)
        user
      end

      it 'includes only two options' do
        expect(options.size).to eq(2)
        expect(options.map(&:last)).to contain_exactly('applicant', 'contact')
      end

      it 'does not include organization option' do
        organization_option = options.find { |opt| opt.last == 'organization' }
        expect(organization_option).to be_nil
      end
    end
  end

  describe '#search_builder' do
    it 'returns AuthorizationsSearchEngineBuilder for Authorization model' do
      builder = facade.send(:search_builder)
      expect(builder).to be_a(AuthorizationsSearchEngineBuilder)
    end

    context 'with AuthorizationRequest model' do
      let(:scoped_relation) { AuthorizationRequest.where(organization: organization) }
      let(:concrete_facade) do
        Class.new(AbstractDashboardFacade) do
          def model_class
            AuthorizationRequest
          end

          def displayed_states
            %w[draft submitted]
          end
        end
      end

      it 'returns AuthorizationRequestsSearchEngineBuilder' do
        builder = facade.send(:search_builder)
        expect(builder).to be_a(AuthorizationRequestsSearchEngineBuilder)
      end
    end
  end
end
