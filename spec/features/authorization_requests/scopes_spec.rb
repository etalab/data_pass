RSpec.describe 'Authorization request with a scope step' do
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
        click_button 'next_authorization_request'
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

        click_button 'next_authorization_request'
      end
    end

    it 'changes scopes and change step' do
      expect {
        submitting_without_scope
      }.to change { authorization_request.reload.scopes }.to(['cnaf_quotient_familial'])

      expect(page).not_to have_css('.fr-alert')
      expect(page).not_to have_current_path(authorization_request_form_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: scope_step_name))
    end
  end
end
