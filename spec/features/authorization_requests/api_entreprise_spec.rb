RSpec.describe 'Start API Entreprise authorization request', :js do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'use case filtering' do
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

  describe 'no available editor' do
    before do
      visit choose_authorization_request_form_path(authorization_definition_id: 'api_entreprise')

      find('label', text: 'Votre éditeur').click

      within('#editors-list') do
        find('label', text: editor).click
      end
    end

    context 'when editor has forms' do
      let(:editor) { 'MGDIS' }

      it 'shows editors forms' do
        expect(page).to have_css('.authorization-request-form-card', count: 1)

        expect(page).to have_css('#authorization_request_form_api-entreprise-mgdis')
      end
    end

    context 'when editor has no forms (choose none)' do
      let(:editor) { 'Aucun' }

      it 'shows no forms' do
        expect(page).to have_css('#no-editor-disclaimer')
      end
    end
  end
end
