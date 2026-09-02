RSpec.describe 'Authorization request with multiple steps' do
  let(:user) { create(:user) }
  let(:authorization_request) { build(:authorization_request, :api_entreprise, applicant: user) }
  let(:authorization_request_form) { authorization_request.form }

  let(:first_step_name) { I18n.t("wicked.#{authorization_request_form.steps[0][:name]}") }
  let(:second_step_name) { I18n.t("wicked.#{authorization_request_form.steps[1][:name]}") }
  let(:last_step_name) { I18n.t("wicked.#{authorization_request_form.steps[-1][:name]}") }

  before do
    sign_in(user)
  end

  describe 'new habilitation' do
    describe 'click on start' do
      subject(:start_new_habilitation) do
        visit new_authorization_request_form_path(form_uid: authorization_request_form.uid)

        click_link_or_button dom_id(authorization_request_form, :start_authorization_request)
      end

      it 'does not create a new habilitation, redirect to first step' do
        expect {
          start_new_habilitation
        }.not_to change(AuthorizationRequest, :count)

        expect(page).to have_current_path(start_authorization_request_forms_path(form_uid: authorization_request_form.uid))
      end
    end
  end

  describe 'visiting an unknown wizard step' do
    let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }

    it 'returns a 404 instead of a 500' do
      visit authorization_request_form_build_path(
        form_uid: authorization_request_form.uid,
        authorization_request_id: authorization_request.id,
        id: 'evil@step',
      )

      expect(page.status_code).to eq(404)
    end
  end

  describe 'start with a step in the query' do
    let(:first_step_title) do
      step = authorization_request_form.steps.first[:name]

      I18n.t(
        "authorization_request_forms.#{authorization_request.model_name.element}.steps.#{step}",
        default: I18n.t("authorization_request_forms.default.steps.#{step}")
      )
    end

    %w[evil@step scopes donnees].each do |ignored_step|
      it "ignores « #{ignored_step} » and renders the first step" do
        visit start_authorization_request_forms_path(form_uid: authorization_request_form.uid, id: ignored_step)

        expect(page.status_code).to eq(200)
        expect(page).to have_css('[data-fr-current-step="1"]')
        expect(page.title).to start_with(first_step_title)
      end
    end
  end

  describe 'resume habilitation' do
    subject(:resume_habilitation) do
      visit authorization_request_form_path(form_uid: authorization_request_form.uid, id: authorization_request.id)
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }

    it 'redirects to first step' do
      resume_habilitation

      expect(page).to have_current_path(authorization_request_form_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: first_step_name))
    end
  end

  describe 'move to another step' do
    subject(:move_to_next_step) do
      visit authorization_request_form_path(form_uid: authorization_request_form.uid, id: authorization_request.id)

      within(css_id(authorization_request)) do
        fill_in input_identifier(authorization_request_class, :intitule), with: intitule
        fill_in input_identifier(authorization_request_class, :description), with: description

        click_link_or_button 'next_authorization_request'
      end
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :no_checkboxes, applicant: user) }
    let(:authorization_request_class) { authorization_request_form.authorization_request_class }
    let(:description) { 'My new description' }

    context 'with valid data' do
      let(:intitule) { 'My new intitule' }

      it 'works and save' do
        expect {
          move_to_next_step
        }.to change { authorization_request.reload.intitule }.to(intitule)

        expect(page).to have_current_path(authorization_request_form_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: second_step_name))
      end

      describe 'when we returned to the form' do
        subject(:save_and_return_to_the_form) do
          move_to_next_step

          visit authorization_request_form_path(form_uid: authorization_request_form.uid, id: authorization_request.id)
        end

        it 'returns to the last step' do
          save_and_return_to_the_form

          expect(page).to have_current_path(authorization_request_form_build_path(form_uid: authorization_request_form.uid, authorization_request_id: authorization_request.id, id: second_step_name))
        end
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
      visit summary_authorization_request_form_path(form_uid: authorization_request_form.uid, id: authorization_request.id)

      click_link_or_button 'submit_authorization_request'
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, fill_all_attributes: true, applicant: user) }

    context 'with valid data' do
      it 'changes the state of the habilitation and redirects to dashboard path' do
        expect {
          submit_habilitation
        }.to change { authorization_request.reload.state }.to('submitted')

        expect(page).to have_current_path(/#{dashboard_path}/)
      end
    end

    context 'with invalid data' do
      before do
        authorization_request.update!(terms_of_service_accepted: false)
      end

      it 'renders summary view' do
        submit_habilitation

        expect(page).to have_css(css_id(authorization_request, :summary))
        expect(page).to have_css('#submit_authorization_request')
      end
    end
  end

  context 'when habilitation is submitted' do
    subject(:visit_habilitation) do
      visit authorization_request_form_path(form_uid: authorization_request_form.uid, id: authorization_request.id)
    end

    let(:authorization_request) { create(:authorization_request, :api_entreprise, :submitted, applicant: user) }

    it 'redirects to summary, with no submit button' do
      visit_habilitation

      expect(page).to have_current_path(summary_authorization_request_form_path(form_uid: authorization_request_form.uid, id: authorization_request.id))
      expect(page).to have_no_button('submit_authorization_request')
    end
  end
end
