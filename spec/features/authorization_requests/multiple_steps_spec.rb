RSpec.describe 'Authorization request with multiple steps' do
  let(:user) { create(:user) }
  let(:authorization_request) { build(:authorization_request, :api_entreprise, applicant: user) }
  let(:authorization_request_form) { authorization_request.form }

  before do
    sign_in(user)
  end

  describe 'new habilitation' do
    describe 'visiting' do
      subject(:visit_new_habilitation) do
        visit new_authorization_request_path(form_uid: authorization_request_form.uid)
      end

      context 'when there is already a habilitation in progress' do
        let!(:another_authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }

        it 'displays a warning' do
          visit_new_habilitation

          expect(page).to have_css('.fr-alert--warning')
        end
      end
    end

    describe 'submitting the form' do
      subject(:start_new_habilitation) do
        visit new_authorization_request_path(form_uid: authorization_request_form.uid)

        within('#new_authorization_request_api_entreprise') do
          click_button 'start_authorization_request'
        end
      end

      it 'creates a new habilitation and redirect to first step' do
        expect {
          start_new_habilitation
        }.to change(AuthorizationRequest, :count).by(1)

        authorization_request = AuthorizationRequest.last

        expect(page).to have_current_path(authorization_request_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: authorization_request_form.steps.first[:name]))
      end
    end
  end

  describe 'resume habilitation' do
    subject(:resume_habilitation) do
      visit authorization_request_path(form_uid: authorization_request_form.uid, id: authorization_request.id)
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }

    it 'redirects to first step' do
      resume_habilitation

      expect(page).to have_current_path(authorization_request_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: authorization_request_form.steps.first[:name]))
    end
  end

  describe 'move to another step' do
    subject(:move_to_next_step) do
      visit authorization_request_path(form_uid: authorization_request_form.uid, id: authorization_request.id)

      within(css_id(authorization_request)) do
        fill_in input_identifier(authorization_request_class, :intitule), with: intitule
        fill_in input_identifier(authorization_request_class, :description), with: description

        click_button 'next_authorization_request'
      end
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :no_checkboxes, applicant: user) }
    let(:authorization_request_class) { authorization_request_form.authorization_request_class }
    let(:next_step_name) { authorization_request.form.steps[1][:name] }
    let(:description) { 'My new description' }

    context 'with valid data' do
      let(:intitule) { 'My new intitule' }

      it 'works and save' do
        expect {
          move_to_next_step
        }.to change { authorization_request.reload.intitule }.to(intitule)

        expect(page).to have_current_path(authorization_request_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: next_step_name))
      end
    end

    context 'with invalid data' do
      let(:intitule) { nil }

      it 'does not work and display errors' do
        expect {
          move_to_next_step
        }.not_to change { authorization_request.reload.description }

        expect(page).to have_css('.fr-alert')
      end
    end
  end

  describe 'submit the habilitation' do
    subject(:submit_habilitation) do
      visit authorization_request_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: 'finish')

      within(css_id(authorization_request)) do
        click_button 'submit_authorization_request'
      end
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, fill_all_attributes: true, applicant: user) }

    context 'with valid data' do
      it 'changes the state of the habilitation and redirects to dashboard path' do
        expect {
          submit_habilitation
        }.to change { authorization_request.reload.state }.to('submitted')

        expect(page).to have_current_path(dashboard_path)
      end
    end

    context 'with invalid data' do
      before do
        authorization_request.update!(terms_of_service_accepted: false)
      end

      it 'renders finish view' do
        submit_habilitation

        expect(page).to have_current_path(authorization_request_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: 'finish'))
        expect(page).to have_css('#submit_authorization_request')
      end
    end
  end

  context 'when habilitation is submitted' do
    subject(:visit_habilitation) do
      visit authorization_request_path(form_uid: authorization_request_form.uid, id: authorization_request.id)
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, applicant: user) }

    it 'redirects to finish path, with no submit button' do
      visit_habilitation

      expect(page).to have_current_path(authorization_request_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: 'finish'))
      expect(page).not_to have_button('submit_authorization_request')
    end
  end
end
