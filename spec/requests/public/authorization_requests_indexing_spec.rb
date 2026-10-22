RSpec.describe 'Public authorization request pages indexing' do
  let(:authorization_request) { create(:authorization_request, :api_entreprise) }
  let(:robots_meta_tag) { 'meta[name="robots"][content="noindex, nofollow"]' }

  describe 'GET /public/demandes/:id' do
    it 'asks search engines not to index the page through an HTTP header' do
      get public_authorization_request_path(authorization_request.public_id)

      expect(response).to have_http_status(:ok)
      expect(response.headers['X-Robots-Tag']).to eq('noindex, nofollow')
    end

    it 'asks search engines not to index the page through a meta tag' do
      get public_authorization_request_path(authorization_request.public_id)

      expect(response.parsed_body.css(robots_meta_tag)).to be_present
    end

    it 'sends the HTTP header when the request is unknown' do
      get public_authorization_request_path(SecureRandom.uuid)

      expect(response).to redirect_to(root_path)
      expect(response.headers['X-Robots-Tag']).to eq('noindex, nofollow')
    end
  end

  describe 'other pages' do
    it 'does not prevent the home page from being indexed' do
      get root_path

      expect(response.headers['X-Robots-Tag']).to be_nil
      expect(response.parsed_body.css('meta[name="robots"]')).to be_empty
    end

    it 'does not prevent the stats page from being indexed' do
      get stats_path

      expect(response.headers['X-Robots-Tag']).to be_nil
      expect(response.parsed_body.css('meta[name="robots"]')).to be_empty
    end

    it 'does not add the meta tag on the authenticated summary of a request' do
      sign_in(authorization_request.applicant)

      get summary_authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id)

      expect(response.headers['X-Robots-Tag']).to be_nil
      expect(response.parsed_body.css('meta[name="robots"]')).to be_empty
    end
  end
end
