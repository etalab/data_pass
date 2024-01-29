RSpec.describe 'Start API Entreprise authorization request', :js do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'when we do not have a use_case in the url' do
    before do
      visit choose_authorization_request_form_path(authorization_definition_id: 'api_entreprise')
    end

    context 'when we choose internal team' do
      before do
        find('label', text: 'Vos développeurs').click
      end

      it 'shows more forms with the default one' do
        expect(all('.authorization-request-form-card').count).to be > 2

        expect(page).to have_css('#authorization_request_form_api-entreprise')
        expect(page).to have_css('#authorization_request_form_api-entreprise-marches-publics')
        expect(page).to have_css('#authorization_request_form_api-entreprise-aides-publiques')
      end
    end
  end

  describe 'when we have a use_case in the url' do
    let(:use_case) { 'marches_publics' }

    before do
      visit choose_authorization_request_form_path(authorization_definition_id: 'api_entreprise', use_case:)
    end

    context 'when we choose internal team' do
      before do
        find('label', text: 'Vos développeurs').click
      end

      it 'shows only this form with the default one' do
        expect(page).to have_css('.authorization-request-form-card', count: 2)

        expect(page).to have_css('#authorization_request_form_api-entreprise')
        expect(page).to have_css('#authorization_request_form_api-entreprise-marches-publics')
      end
    end
  end
end
