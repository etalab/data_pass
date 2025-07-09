RSpec.describe 'Instruction: habilitations search' do
  subject(:search) do
    visit instruction_dashboard_show_path(id: 'habilitations')

    within('#authorization_search') do
      fill_in 'instructor_search_input', with: search_text if use_search_text
      select state, from: 'search_query_state_eq' if state
      select type, from: 'search_query_authorization_request_class_eq' if type

      click_link_or_button
    end
  end

  let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier]) }
  let(:organization) { create(:organization, siret: '13002526500013') }

  let(:search_text) { 'My search text' }
  let(:intitule) { search_text }

  before do
    sign_in(user)
  end

  context 'when we search with text, state and type' do
    let(:use_search_text) { true }
    let(:state) { 'Active' }
    let(:type) { 'API Entreprise' }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:invalid_type_request) { create(:authorization_request, :api_particulier, :submitted, intitule: intitule) }
    let!(:invalid_state_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule) }
    let!(:invalid_intitule_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: 'not valid') }

    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }
    let!(:invalid_type_authorization) { create(:authorization, request: invalid_type_request, state: :active) }
    let!(:invalid_state_authorization) { create(:authorization, request: invalid_state_request, state: :obsolete) }
    let!(:invalid_intitule_authorization) { create(:authorization, request: invalid_intitule_request, state: :active) }

    it 'renders only one authorization' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization))
    end
  end

  context 'when we search with text and state' do
    let(:use_search_text) { true }
    let(:state) { 'Active' }
    let(:type) { nil }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:invalid_type_request) { create(:authorization_request, :api_particulier, :submitted, intitule: intitule) }
    let!(:invalid_state_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule) }
    let!(:invalid_intitule_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: 'not valid') }

    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }
    let!(:invalid_type_authorization) { create(:authorization, request: invalid_type_request, state: :active) }
    let!(:invalid_state_authorization) { create(:authorization, request: invalid_state_request, state: :obsolete) }
    let!(:invalid_intitule_authorization) { create(:authorization, request: invalid_intitule_request, state: :active) }

    it 'renders 2 valid authorizations' do
      search

      expect(page).to have_css('.authorization-request', count: 2)
      expect(page).to have_css(css_id(valid_searched_authorization))
      expect(page).to have_css(css_id(invalid_type_authorization))
    end
  end

  context 'when we search with text and type' do
    let(:use_search_text) { true }
    let(:state) { nil }
    let(:type) { 'API Entreprise' }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:invalid_type_request) { create(:authorization_request, :api_particulier, :submitted, intitule: intitule) }
    let!(:invalid_state_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule) }
    let!(:invalid_intitule_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: 'not valid') }

    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }
    let!(:invalid_type_authorization) { create(:authorization, request: invalid_type_request, state: :active) }
    let!(:invalid_state_authorization) { create(:authorization, request: invalid_state_request, state: :obsolete) }
    let!(:invalid_intitule_authorization) { create(:authorization, request: invalid_intitule_request, state: :active) }

    it 'renders 2 valid authorizations' do
      search

      expect(page).to have_css('.authorization-request', count: 2)
      expect(page).to have_css(css_id(valid_searched_authorization))
      expect(page).to have_css(css_id(invalid_state_authorization))
    end
  end

  context 'when we search with state and type' do
    let(:use_search_text) { false }
    let(:state) { 'Active' }
    let(:type) { 'API Entreprise' }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:invalid_type_request) { create(:authorization_request, :api_particulier, :submitted, intitule: intitule) }
    let!(:invalid_state_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule) }
    let!(:invalid_intitule_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: 'not valid') }

    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }
    let!(:invalid_type_authorization) { create(:authorization, request: invalid_type_request, state: :active) }
    let!(:invalid_state_authorization) { create(:authorization, request: invalid_state_request, state: :obsolete) }
    let!(:invalid_intitule_authorization) { create(:authorization, request: invalid_intitule_request, state: :active) }

    it 'renders 2 valid authorizations' do
      search

      expect(page).to have_css('.authorization-request', count: 2)
      expect(page).to have_css(css_id(valid_searched_authorization))
      expect(page).to have_css(css_id(invalid_intitule_authorization))
    end
  end

  context 'when we use organization siret' do
    let(:use_search_text) { true }
    let(:search_text) { organization.siret }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }

    it 'renders authorization linked to this siret' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization))
    end
  end

  context 'when we use organization raison sociale' do
    let(:use_search_text) { true }
    let(:search_text) { 'interministerielle' }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }

    it 'renders authorization linked to this raison sociale' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization))
    end
  end

  context 'when we use applicant email' do
    let(:use_search_text) { true }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }
    let(:search_text) { valid_searched_authorization.applicant.email }

    it 'renders authorization linked to this applicant' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization))
    end
  end

  context 'when we use applicant family name' do
    let(:use_search_text) { true }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
    let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }
    let(:search_text) { valid_searched_authorization.applicant.family_name }

    before do
      valid_searched_authorization.applicant.update(family_name: 'My family name')
    end

    it 'renders authorization linked to this applicant' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization))
    end
  end

  context 'when we use an id' do
    let(:use_search_text) { true }
    let(:state) { nil }
    let(:type) { nil }
    let(:intitule) { 'whatever' }

    context 'when we can see this authorization' do
      let!(:valid_request) { create(:authorization_request, :api_entreprise, :submitted, intitule: intitule, organization: organization) }
      let!(:valid_searched_authorization) { create(:authorization, request: valid_request, state: :active) }
      let(:search_text) { valid_searched_authorization.id.to_s }

      it 'redirects to the authorization' do
        search

        expect(page).to have_current_path(authorization_path(valid_searched_authorization))
      end
    end

    context 'when we can not see this authorization' do
      let!(:foreign_request) { create(:authorization_request, :hubee_dila, :submitted) }
      let!(:foreign_authorization) { create(:authorization, request: foreign_request, state: :active) }
      let(:search_text) { foreign_authorization.id.to_s }

      it 'does not redirect to the authorization, and renders nothing' do
        search

        expect(page).to have_current_path(instruction_dashboard_show_path(id: 'habilitations'), ignore_query: true)
        expect(page).to have_css('.authorization-request', count: 0)
      end
    end
  end
end
