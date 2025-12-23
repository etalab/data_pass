RSpec.describe 'Instruction: demandes search' do
  subject(:search) do
    visit instruction_dashboard_show_path(id: 'demandes')

    within('#authorization_request_search') do
      fill_in 'instructor_search_input', with: search_text if use_search_text
      select_multi_select_option(state, from: '#search_query_state_in') if state
      select_multi_select_option(type, from: '#search_query_type_in') if type

      click_link_or_button 'Rechercher'
    end
  end

  let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier]) }
  let(:organization) { create(:organization, siret: '13002526500013') }

  let!(:valid_searched_authorization_request) { create(:authorization_request, :api_entreprise, state: :submitted, intitule:, organization:) }

  let!(:invalid_type_authorization_request) { create(:authorization_request, :api_particulier, state: :submitted, intitule:) }
  let!(:invalid_state_authorization_request) { create(:authorization_request, :api_entreprise, state: :draft, intitule:) }
  let!(:invalid_intitule_authorization_request) { create(:authorization_request, :api_entreprise, state: :submitted, intitule: 'not valid') }

  let(:search_text) { 'My search text' }
  let(:intitule) { search_text }

  before do
    sign_in(user)
  end

  context 'when we search with text, state and type' do
    let(:use_search_text) { true }
    let(:state) { "En cours d'instruction" }
    let(:type) { 'API Entreprise' }

    it 'renders only one authorization request' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
    end
  end

  context 'when we search with text and state' do
    let(:use_search_text) { true }
    let(:state) { "En cours d'instruction" }
    let(:type) { nil }

    it 'renders 2 valids authorization requests' do
      search

      expect(page).to have_css('.authorization-request', count: 2)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
      expect(page).to have_css(css_id(invalid_type_authorization_request))
    end
  end

  context 'when we search with text and type' do
    let(:use_search_text) { true }
    let(:state) { nil }
    let(:type) { 'API Entreprise' }

    it 'renders 2 valids authorization requests' do
      search

      expect(page).to have_css('.authorization-request', count: 2)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
      expect(page).to have_css(css_id(invalid_state_authorization_request))
    end
  end

  context 'when we search with state and type' do
    let(:use_search_text) { false }
    let(:state) { "En cours d'instruction" }
    let(:type) { 'API Entreprise' }

    it 'renders 2 valids authorization requests' do
      search

      expect(page).to have_css('.authorization-request', count: 2)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
      expect(page).to have_css(css_id(invalid_intitule_authorization_request))
    end
  end

  context 'when we use organization siret' do
    let(:use_search_text) { true }
    let(:search_text) { organization.siret }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    it 'renders authorization request linked to this siret' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
    end
  end

  context 'when we use organization raison sociale' do
    let(:use_search_text) { true }
    let(:search_text) { 'interministerielle' }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    it 'renders authorization request linked to this raison sociale' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
    end
  end

  context 'when we use applicant email' do
    let(:use_search_text) { true }
    let(:search_text) { valid_searched_authorization_request.applicant.email }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    it 'renders authorization request linked to this applicant' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
    end
  end

  context 'when we use applicant family name' do
    let(:use_search_text) { true }
    let(:search_text) { valid_searched_authorization_request.applicant.family_name }
    let(:intitule) { 'whatever' }
    let(:state) { nil }
    let(:type) { nil }

    before do
      valid_searched_authorization_request.applicant.update(family_name: 'My family name')
    end

    it 'renders authorization request linked to this applicant' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
    end
  end

  context 'when we use an id' do
    let(:use_search_text) { true }
    let(:state) { nil }
    let(:type) { nil }
    let(:intitule) { 'whatever' }

    context 'when we can see this authorization request' do
      let(:search_text) { valid_searched_authorization_request.id.to_s }

      it 'redirects to the authorization request' do
        search

        expect(page).to have_current_path(instruction_authorization_request_path(valid_searched_authorization_request))
      end
    end

    context 'when we can not see this authorization request' do
      let(:foreign_authorization_request) { create(:authorization_request, :hubee_dila, state: :validated) }
      let(:search_text) { foreign_authorization_request.id.to_s }

      it 'does not redirects to the authorization request, and renders nothing' do
        search

        expect(page).to have_current_path(instruction_dashboard_show_path(id: 'demandes'), ignore_query: true)
        expect(page).to have_css('.authorization-request', count: 0)
      end
    end
  end

  context 'when we search with multiple states' do
    let(:use_search_text) { true }
    let(:search_text) { 'Multiple states test unique' }
    let(:state) { nil }
    let(:type) { nil }

    # Create requests with unique intitule to avoid conflicts with other tests
    let!(:submitted_request) { create(:authorization_request, :api_entreprise, state: :submitted, intitule: search_text, organization: organization) }
    let!(:draft_request) { create(:authorization_request, :api_particulier, state: :draft, intitule: search_text) }
    let!(:refused_request) { create(:authorization_request, :api_entreprise, state: :refused, intitule: search_text) }

    it 'renders requests with both selected states and filters out the other state' do
      visit instruction_dashboard_show_path(id: 'demandes')

      within('#authorization_request_search') do
        fill_in 'instructor_search_input', with: search_text
        select_multi_select_option("En cours d'instruction", from: '#search_query_state_in')
        select_multi_select_option('Brouillon', from: '#search_query_state_in')

        click_link_or_button 'Rechercher'
      end

      # Verify the two matching requests are present
      expect(page).to have_css(css_id(submitted_request))
      expect(page).to have_css(css_id(draft_request))

      # Verify the filtered out request is not present
      expect(page).to have_no_css(css_id(refused_request))
    end
  end
end
