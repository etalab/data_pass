RSpec.describe 'Authorization request with scopes' do
  describe 'at the scope step' do
    let(:user) { create(:user) }
    let(:authorization_request) do
      authorization_request = create(:authorization_request, :api_particulier, fill_all_attributes: true, applicant: user)
      authorization_request.current_build_step = 'basic_infos'
      authorization_request.scopes = nil
      authorization_request.save!
      authorization_request
    end
    let(:authorization_request_form) { authorization_request.form }

    let(:scope_step_name) { I18n.t('wicked.scopes') }

    before do
      sign_in(user)

      visit authorization_request_form_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: scope_step_name)
    end

    describe 'submitting no scope' do
      subject(:submitting_without_scope) do
        within(css_id(authorization_request)) do
          click_link_or_button 'next_authorization_request'
        end
      end

      it 'does not change scopes and displays an error' do
        expect {
          submitting_without_scope
        }.not_to change { authorization_request.reload.scopes }

        expect(page).to have_css('.fr-alert')
      end
    end

    describe 'submitting with one scope' do
      subject(:submitting_without_scope) do
        within(css_id(authorization_request)) do
          check 'authorization_request_api_particulier_scopes_cnaf_quotient_familial'

          click_link_or_button 'next_authorization_request'
        end
      end

      it 'changes scopes and change step' do
        expect {
          submitting_without_scope
        }.to change { authorization_request.reload.scopes }.to(['cnaf_quotient_familial'])

        expect(page).to have_no_css('.fr-alert--error')
        expect(page).to have_no_current_path(authorization_request_form_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: scope_step_name))
      end
    end
  end

  describe 'provider-aware scope headings on the interactive picker' do
    let(:user) { create(:user) }
    let(:authorization_request) do
      authorization_request = create(:authorization_request, :api_particulier, fill_all_attributes: true, applicant: user)
      authorization_request.current_build_step = 'basic_infos'
      authorization_request.scopes = nil
      authorization_request.save!
      authorization_request
    end
    let(:authorization_request_form) { authorization_request.form }
    let(:scope_step_name) { I18n.t('wicked.scopes') }

    before do
      sign_in(user)

      visit authorization_request_form_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: scope_step_name)
    end

    it 'shows the combined "provider — group" heading for a scope that has both' do
      expect(page).to have_text('CNAF & MSA — API Quotient familial')
    end
  end

  describe 'provider-aware scope headings on the read-only summary' do
    let(:user) { create(:user) }
    let(:authorization_request) do
      authorization_request = create(:authorization_request, :api_particulier, fill_all_attributes: true, applicant: user)
      authorization_request.scopes = %w[cnaf_quotient_familial]
      authorization_request.save!
      authorization_request
    end

    before do
      sign_in(user)

      visit summary_authorization_request_form_path(form_uid: authorization_request.form.uid, id: authorization_request.id)
    end

    it 'shows the combined "provider — group" heading for a scope that has both' do
      expect(page).to have_text('CNAF & MSA — API Quotient familial')
    end
  end

  describe 'FranceConnect scope visibility guard on the read-only summary' do
    let(:user) { create(:user) }
    let(:authorization_request) do
      create(:authorization_request, :api_particulier_entrouvert_publik, :with_france_connect_embedded_fields, :submitted, applicant: user)
    end

    before do
      ServiceProvider.find('entrouvert').apipfc_enabled = false

      sign_in(user)

      visit summary_authorization_request_form_path(form_uid: authorization_request.form.uid, id: authorization_request.id)
    end

    it 'hides the FranceConnect identity scopes when the modality is selected but the form is not FranceConnect-certified' do
      expect(authorization_request.france_connect_modality?).to be true
      expect(authorization_request.france_connect_authorization_id).to be_blank
      expect(authorization_request.france_connect_certified_form?).to be false

      expect(page).to have_no_text('Nom de famille')
      expect(page).to have_no_text('Prénoms')
    end
  end

  describe 'at the review step, with some scopes defined' do
    let(:user) { create(:user) }
    let(:authorization_request) do
      authorization_request = create(:authorization_request, :api_entreprise, fill_all_attributes: true, applicant: user)
      authorization_request.scopes = default_scopes + additional_scopes
      authorization_request.save!
      authorization_request
    end
    let(:default_scopes) { AuthorizationDefinition.find('api_entreprise').scopes.select(&:included?).map(&:value) }
    let(:additional_scopes) { %w[unites_legales_etablissements_insee] }

    before do
      sign_in(user)

      visit summary_authorization_request_form_path(form_uid: authorization_request.form.uid, id: authorization_request.id)
    end

    it 'keeps the scopes on submit' do
      check 'authorization_request_api_entreprise_terms_of_service_accepted'
      check 'authorization_request_api_entreprise_data_protection_officer_informed'

      click_on 'submit_authorization_request'

      expect(authorization_request.reload.scopes).to match_array(default_scopes + additional_scopes)
    end
  end
end
