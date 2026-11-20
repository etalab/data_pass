RSpec.describe 'Refresh of the identity of the organization in a request' do
  subject(:refresh_identity) do
    post authorization_request_form_identity_refresh_path(form_uid: authorization_request.form_uid, authorization_request_id: authorization_request.id)

    response
  end

  let(:user) { create(:user) }
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user, organization:) }

  before do
    user.add_to_organization(organization, current: true)
    organization.update!(last_insee_payload_updated_at: 2.days.ago)
    sign_in(user)
  end

  context 'when the INSEE renamed the organization since the copy' do
    before do
      authorization_request
      mock_insee_authentication
      renamed_payload = insee_sirene_api_etablissement_valid_payload(siret: '21920023500014', full: true)
        .deep_merge('etablissement' => { 'uniteLegale' => { 'denominationUniteLegale' => 'VILLE DE CLAMART' } })
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: renamed_payload.to_json)
    end

    it 'copies the fresh identity and says the information is up to date' do
      expect(refresh_identity).to have_http_status(:redirect)
      expect(flash[:success]['title']).to eq('Les informations de votre organisation sont à jour.')
      expect(authorization_request.reload.identity_legal_name).to eq('VILLE DE CLAMART')
    end
  end

  context 'when the INSEE data was read less than a day ago' do
    before do
      authorization_request
      organization.update!(last_insee_payload_updated_at: 1.hour.ago)
      mock_insee_authentication
      renamed_payload = insee_sirene_api_etablissement_valid_payload(siret: '21920023500014', full: true)
        .deep_merge('etablissement' => { 'uniteLegale' => { 'denominationUniteLegale' => 'VILLE DE CLAMART' } })
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: renamed_payload.to_json)
    end

    it 'calls the INSEE anyway before saying the information is up to date' do
      refresh_identity

      expect(flash[:success]['title']).to eq('Les informations de votre organisation sont à jour.')
      expect(authorization_request.reload.identity_legal_name).to eq('VILLE DE CLAMART')
    end
  end

  context 'when the refresh comes from the step, through Turbo' do
    subject(:refresh_identity) do
      post authorization_request_form_identity_refresh_path(form_uid: authorization_request.form_uid, authorization_request_id: authorization_request.id), as: :turbo_stream

      response
    end

    before do
      authorization_request
      mock_insee_sirene_api_etablissement_valid(siret: '21920023500014', full: true)
    end

    it 'replaces the identity in the block and shows the result there' do
      expect(refresh_identity.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include('target="wallet-identity-panel"', 'target="wallet-identity-status"', 'Les informations de votre organisation sont à jour.')
    end
  end

  context 'when Sirene does not answer' do
    before do
      authorization_request
      mock_insee_authentication
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 503)
    end

    it 'warns that nothing changed and points to the support' do
      refresh_identity

      expect(flash[:warning]['title']).to eq('Le répertoire Sirene ne répond pas')
      expect(flash[:warning]['description']).to include('datapass@api.gouv.fr')
    end
  end

  context 'when the identity is still loading and the INSEE answers' do
    subject(:refresh_identity) do
      post authorization_request_form_identity_refresh_path(form_uid: authorization_request.form_uid, authorization_request_id: authorization_request.id), as: :turbo_stream

      response
    end

    let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user, organization:, identity_source: 'sirene_pending') }

    before { mock_insee_sirene_api_etablissement_valid(siret: '21920023500014', full: true) }

    it 'copies the identity and reloads the step, whose block changes shape' do
      expect(refresh_identity).to have_http_status(:see_other)
      expect(flash[:success]['title']).to eq('Les informations de votre organisation sont à jour.')
      expect(authorization_request.reload.identity_source).to eq('sirene')
      expect(authorization_request.identity_legal_name).to eq('COMMUNE DE CLAMART')
    end
  end

  context 'when the identity is still loading and Sirene does not answer' do
    let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user, organization:, identity_source: 'sirene_pending') }

    before do
      mock_insee_authentication
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 503)
    end

    it 'gives up loading: the step explains the applicant types the identity, and can try again' do
      refresh_identity

      expect(authorization_request.reload.identity_source).to eq('sirene_unavailable')
      expect(flash[:warning]).to be_nil
    end
  end

  context 'when nothing could be retrieved and Sirene answers on a new try' do
    let(:authorization_request) { create(:authorization_request, :registre_wallet, applicant: user, organization:, identity_source: 'sirene_unavailable') }

    before { mock_insee_sirene_api_etablissement_valid(siret: '21920023500014', full: true) }

    it 'copies the identity' do
      refresh_identity

      expect(authorization_request.reload.identity_source).to eq('sirene')
    end
  end

  context 'with a submitted request' do
    let(:submitted_request) { create(:authorization_request, :registre_wallet, :submitted, applicant: user, organization:) }

    before { mock_insee_sirene_api_etablissement_valid(siret: '21920023500014', full: true) }

    it 'refuses the refresh and keeps the copy made at submission' do
      expect {
        post authorization_request_form_identity_refresh_path(form_uid: submitted_request.form_uid, authorization_request_id: submitted_request.id)
      }.not_to change { submitted_request.reload.identity_legal_name }
    end
  end
end
