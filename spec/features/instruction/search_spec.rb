RSpec.describe 'Instruction: habilitation search' do
  let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise api_particulier]) }

  let!(:valid_searched_authorization_request) { create(:authorization_request, :api_entreprise, state: :validated, intitule: search_text) }

  let!(:invalid_type_authorization_request) { create(:authorization_request, :api_particulier, state: :validated, intitule: search_text) }
  let!(:invalid_state_authorization_request) { create(:authorization_request, :api_entreprise, state: :draft, intitule: search_text) }
  let!(:invalid_intitule_authorization_request) { create(:authorization_request, :api_entreprise, state: :validated, intitule: 'not valid') }

  let(:search_text) { 'My search text' }

  before do
    sign_in(user)
  end

  context 'when we search with text, state and type' do
    subject(:search) do
      visit instruction_authorization_requests_path

      within('#authorization_request_search') do
        fill_in 'q_within_data_cont', with: search_text
        select 'Validée', from: 'q_state_eq'
        select 'API Entreprise', from: 'q_type_eq'

        click_link_or_button
      end
    end

    it 'renders only one authorization request' do
      search

      expect(page).to have_css('.authorization-request', count: 1)
      expect(page).to have_css(css_id(valid_searched_authorization_request))
    end
  end
end
