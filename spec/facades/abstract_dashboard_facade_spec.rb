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

    context 'when there are mentions from other verified organizations' do
      let(:other_organization) { create(:organization) }
      let(:other_user) { create(:user) }

      before do
        other_user.add_to_organization(other_organization, verified: true, current: true)

        authorization_request = create(:authorization_request, organization: organization, applicant: current_user, state: :validated)
        create_list(:authorization, 8, request: authorization_request, state: :active)

        mentioned_request = create(:authorization_request, :api_entreprise, organization: other_organization, applicant: other_user, state: :validated, contact_metier_email: current_user.email)
        create_list(:authorization, 2, request: mentioned_request, state: :active)
      end

      it 'displays the filters' do
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

  describe '#empty?' do
    subject(:empty) { facade.empty? }

    let(:concrete_facade) do
      Class.new(AbstractDashboardFacade) do
        attr_accessor :highlighted_categories, :categories

        def initialize(user:, search_query:, subdomain_types:, scoped_relation:)
          super
          @highlighted_categories = {}
          @categories = {}
        end

        def data
          { highlighted_categories: @highlighted_categories, categories: @categories, search_engine: nil }
        end

        def model_class
          Authorization
        end

        def displayed_states
          %i[active revoked]
        end
      end
    end

    context 'when all categories are empty' do
      it 'returns true' do
        facade.highlighted_categories = { changes_requested: [] }
        facade.categories = { active: [], revoked: [] }

        expect(empty).to be true
      end
    end

    context 'when highlighted_categories has items' do
      it 'returns false' do
        authorization_request = create(:authorization_request, organization: organization)
        facade.highlighted_categories = { changes_requested: [authorization_request] }
        facade.categories = { active: [], revoked: [] }

        expect(empty).to be false
      end
    end

    context 'when categories has items' do
      it 'returns false' do
        authorization_request = create(:authorization_request, organization: organization)
        facade.highlighted_categories = { changes_requested: [] }
        facade.categories = { active: [authorization_request] }

        expect(empty).to be false
      end
    end
  end

  describe '#total_count' do
    subject(:total_count) { facade.total_count }

    let(:concrete_facade) do
      Class.new(AbstractDashboardFacade) do
        attr_accessor :highlighted_categories, :categories

        def initialize(user:, search_query:, subdomain_types:, scoped_relation:)
          super
          @highlighted_categories = {}
          @categories = {}
        end

        def data
          { highlighted_categories: @highlighted_categories, categories: @categories, search_engine: nil }
        end

        def model_class
          Authorization
        end

        def displayed_states
          %i[active revoked]
        end
      end
    end

    it 'returns 0 when all categories are empty' do
      facade.highlighted_categories = { changes_requested: [] }
      facade.categories = { active: [], revoked: [] }

      expect(total_count).to eq(0)
    end

    it 'counts items in highlighted_categories' do
      authorization_requests = create_list(:authorization_request, 3, :api_entreprise, organization: organization)
      facade.highlighted_categories = { changes_requested: authorization_requests }
      facade.categories = { active: [] }

      expect(total_count).to eq(3)
    end

    it 'counts items in categories' do
      authorization_requests = create_list(:authorization_request, 5, :api_entreprise, organization: organization)
      facade.highlighted_categories = {}
      facade.categories = { active: authorization_requests }

      expect(total_count).to eq(5)
    end

    it 'counts items in both highlighted_categories and categories' do
      highlighted_items = create_list(:authorization_request, 2, :api_entreprise, organization: organization)
      category_items = create_list(:authorization_request, 3, :api_entreprise, organization: organization)

      facade.highlighted_categories = { changes_requested: highlighted_items }
      facade.categories = { active: category_items }

      expect(total_count).to eq(5)
    end
  end

  describe '#empty_with_filter?' do
    subject(:no_results_after_filter) { facade.empty_with_filter? }

    let(:concrete_facade) do
      Class.new(AbstractDashboardFacade) do
        attr_accessor :highlighted_categories, :categories

        def initialize(user:, search_query:, subdomain_types:, scoped_relation:)
          super
          @highlighted_categories = {}
          @categories = {}
        end

        def data
          { highlighted_categories: @highlighted_categories, categories: @categories, search_engine: nil }
        end

        def model_class
          Authorization
        end

        def displayed_states
          %i[active revoked]
        end
      end
    end

    context 'when empty and search_query is present' do
      let(:search_query) { { q: 'test' } }

      it 'returns true' do
        facade.highlighted_categories = {}
        facade.categories = {}

        expect(no_results_after_filter).to be true
      end
    end

    context 'when empty but search_query is nil' do
      let(:search_query) { nil }

      it 'returns false' do
        facade.highlighted_categories = {}
        facade.categories = {}

        expect(no_results_after_filter).to be false
      end
    end

    context 'when not empty and search_query is present' do
      let(:search_query) { { q: 'test' } }

      it 'returns false' do
        authorization_request = create(:authorization_request, organization: organization)
        facade.highlighted_categories = {}
        facade.categories = { active: [authorization_request] }

        expect(no_results_after_filter).to be false
      end
    end
  end
end
