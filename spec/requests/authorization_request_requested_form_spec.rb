RSpec.describe 'Definition page for a form asked by a partner link' do
  it 'shows the eligibility tree to a signed-out visitor, with buttons that keep the form' do
    get new_authorization_request_path(definition_id: 'api_particulier', formulaire: 'api-particulier')

    expect(response.parsed_body.css('a[href*="eligibility_confirmed=true"]').pluck('href')).to all(include('formulaire=api-particulier'))
  end

  it 'keeps the introduction of the partner link as the page to come back to after signing in, with its prefill' do
    get authorization_request_form_introduction_path(form_uid: 'api-particulier', intitule: 'Mon service')
    get new_authorization_request_path(definition_id: 'api_particulier', eligibility_confirmed: true, formulaire: 'api-particulier')

    expect(session[:return_to_after_sign_in]).to end_with('/formulaires/api-particulier/demande/nouveau?intitule=Mon+service')
  end

  context 'when the applicant is signed in' do
    before { sign_in(create(:user)) }

    it 'goes straight to the introduction of the form, instead of the choice of forms' do
      get new_authorization_request_path(definition_id: 'api_entreprise', formulaire: 'api-entreprise-marches-publics')

      expect(response).to redirect_to(authorization_request_form_introduction_path(form_uid: 'api-entreprise-marches-publics'))
    end

    it 'ignores a form that does not belong to the definition' do
      get new_authorization_request_path(definition_id: 'api_entreprise', formulaire: 'api-particulier')

      expect(response).to have_http_status(:ok)
    end
  end
end
