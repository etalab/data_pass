RSpec.describe 'Submit authorization request' do
  let(:user) { create(:user, :with_organization) }
  let(:authorization_request) { create(:authorization_request, applicant: user) }
  let(:authorization_request_form) { authorization_request.form_model }
  let(:authorization_request_class) { authorization_request_form.authorization_request_class }

  before do
    sign_in(user)
  end

  describe 'elements' do
    subject do
      visit authorization_request_path(form_uid: authorization_request_form.uid, id: authorization_request.id)

      page
    end

    it 'does a submit authorization request button' do
      expect(subject).to have_button('submit_authorization_request')
    end
  end

  describe 'access' do
    context 'when user is not the applicant' do
      let(:user) { create(:user) }
      let(:authorization_request) { create(:authorization_request) }

      it 'does not allow access' do
        visit authorization_request_path(form_uid: authorization_request_form.uid, id: authorization_request.id)

        expect(current_path).to eq(dashboard_path)
      end
    end
  end

  describe 'submitting the form' do
    subject do
      visit authorization_request_path(form_uid: authorization_request_form.uid, id: authorization_request.id)

      within(css_id(authorization_request)) do
        fill_in input_identifier(authorization_request_class, :intitule), with: 'Intitulé de la demande'
        fill_in input_identifier(authorization_request_class, :description), with: 'Description de la demande'

        fill_in input_identifier(authorization_request_class, :administrateur_metier_email), with: 'metier@gouv.fr'
        fill_in input_identifier(authorization_request_class, :administrateur_metier_family_name), with: 'Mé'
        fill_in input_identifier(authorization_request_class, :administrateur_metier_given_name), with: 'tier'
        fill_in input_identifier(authorization_request_class, :administrateur_metier_phone_number), with: '0836656565'
        fill_in input_identifier(authorization_request_class, :administrateur_metier_job_title), with: 'Chief Metier Officier'

        click_button 'submit_authorization_request'
      end
    end

    it 'updates authorization request to submit status' do
      expect {
        subject
      }.to change { authorization_request.reload.state }.from('draft').to('submitted')
    end
  end
end
