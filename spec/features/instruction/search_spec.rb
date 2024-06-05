RSpec.describe 'Instruction: habilitation search' do
  subject(:search) do
    visit instruction_authorization_requests_path

    within('#authorization_request_search') do
      fill_in 'q_within_data_or_organization_siret_cont', with: search_text if use_search_text
      select state, from: 'q_state_eq' if state
      select type, from: 'q_type_eq' if type

      click_link_or_button
    end
  end

  let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier]) }
  let(:organization) { create(:organization) }

  let!(:valid_searched_authorization_request) { create(:authorization_request, :api_entreprise, state: :validated, intitule:, organization:) }

  let!(:invalid_type_authorization_request) { create(:authorization_request, :api_particulier, state: :validated, intitule:) }
  let!(:invalid_state_authorization_request) { create(:authorization_request, :api_entreprise, state: :draft, intitule:) }
  let!(:invalid_intitule_authorization_request) { create(:authorization_request, :api_entreprise, state: :validated, intitule: 'not valid') }

  let(:search_text) { 'My search text' }
  let(:intitule) { search_text }

  before do
    sign_in(user)
  end

  context 'when we search with text, state and type' do
    let(:use_search_text) { true }
    let(:state) { 'Validée' }
    let(:type) { 'API Entreprise' }

    it 'renders only one authorization request' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
    end
  end

  context 'when we search with text and state' do
    let(:use_search_text) { true }
    let(:state) { 'Validée' }
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
    let(:state) { 'Validée' }
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

        expect(page).to have_current_path(instruction_authorization_requests_path, ignore_query: true)
        expect(page).to have_css('.authorization-request', count: 0)
      end
    end
  end
end
