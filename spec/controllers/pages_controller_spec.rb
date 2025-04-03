RSpec.describe PagesController do
  describe 'GET #cgu_api_impot_particulier_bas' do
    it 'returns a 200 response' do
      get :cgu_api_impot_particulier_bas
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #cgu_api_impot_particulier_prod' do
    it 'returns a 200 response' do
      get :cgu_api_impot_particulier_prod
      expect(response).to have_http_status(:ok)
    end
  end
end
