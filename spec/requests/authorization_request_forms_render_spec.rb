RSpec.describe 'Authorization request forms rendering' do
  let(:user) { create(:user) }
  let(:authorization_request) { create(:authorization_request, :api_entreprise, applicant: user) }

  before { sign_in(user) }

  describe 'PATCH with an invalid payload on a multiple steps form' do
    subject(:send_invalid_payload) do
      patch authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id),
        params: { review: '1', authorization_request_api_entreprise: { intitule: '' } }
    end

    it 'renders the first step instead of looking for a template named after the request id' do
      send_invalid_payload

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('authorization_request_api_entreprise_intitule')
    end
  end
end
