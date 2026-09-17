RSpec.describe 'Resuming a multiple steps authorization request' do
  let(:user) { create(:user) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }
  let(:build_step_cookie_key) { "demande_#{authorization_request.id}_build_step" }

  let(:first_step_path) { build_step_path(I18n.t('wicked.basic_infos')) }

  def build_step_path(step)
    authorization_request_form_build_path(
      form_uid: authorization_request.form_uid,
      authorization_request_id: authorization_request.id,
      id: step,
    )
  end

  def resume_authorization_request
    get authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id)
  end

  before do
    sign_in(user)
    cookies[build_step_cookie_key] = stored_step
  end

  context 'when the stored step is still part of the form' do
    let(:stored_step) { I18n.t('wicked.personal_data') }

    it 'resumes on the stored step' do
      resume_authorization_request

      expect(response).to redirect_to(build_step_path(stored_step))
    end
  end

  context 'when the stored step has been removed from the form' do
    let(:stored_step) { I18n.t('wicked.technical_team') }

    it 'falls back on the first step' do
      resume_authorization_request

      expect(response).to redirect_to(first_step_path)
    end

    it 'renders the first step on every visit' do
      2.times do
        resume_authorization_request

        expect(response).to redirect_to(first_step_path)

        follow_redirect!

        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'when the stored step is not a known step' do
    let(:stored_step) { 'evil@step' }

    it 'falls back on the first step' do
      resume_authorization_request

      expect(response).to redirect_to(first_step_path)
    end
  end

  context 'when the stored step is the wizard finish step' do
    let(:stored_step) { Wicked::FINISH_STEP }

    it 'falls back on the first step' do
      resume_authorization_request

      expect(response).to redirect_to(first_step_path)
    end
  end
end
