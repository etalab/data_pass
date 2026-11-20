RSpec.describe RefreshAuthorizationRequestIdentity do
  subject(:refresh) { described_class.call(authorization_request:) }

  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:authorization_request) { create(:authorization_request, :registre_wallet, organization:) }

  before do
    authorization_request
    organization.update!(last_insee_payload_updated_at: 2.days.ago)
  end

  def save_website_from_another_request
    AuthorizationRequest.find(authorization_request.id).tap { |request| request.wallet_website_url = 'https://www.clamart.fr' }.save!(validate: false)
  end

  context 'when Sirene answers with a new name' do
    before do
      mock_insee_authentication
      renamed_payload = insee_sirene_api_etablissement_valid_payload(siret: '21920023500014', full: true)
        .deep_merge('etablissement' => { 'uniteLegale' => { 'denominationUniteLegale' => 'VILLE DE CLAMART' } })
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: renamed_payload.to_json)
    end

    it 'copies the fresh identity into the request' do
      expect(refresh).to be_success
      expect(authorization_request.reload.identity_legal_name).to eq('VILLE DE CLAMART')
    end
  end

  context 'when the draft is saved by the applicant while Sirene answers' do
    subject(:refresh) { described_class.call(authorization_request: AuthorizationRequest.find(authorization_request.id)) }

    before do
      mock_insee_authentication
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return do
        save_website_from_another_request
        renamed_payload = insee_sirene_api_etablissement_valid_payload(siret: '21920023500014', full: true)
          .deep_merge('etablissement' => { 'uniteLegale' => { 'denominationUniteLegale' => 'VILLE DE CLAMART' } })
        { status: 200, headers: { 'Content-Type' => 'application/json' }, body: renamed_payload.to_json }
      end
    end

    it 'keeps what the applicant saved meanwhile, with the fresh identity' do
      refresh

      expect(authorization_request.reload.values_at(:wallet_website_url, :identity_legal_name)).to eq(['https://www.clamart.fr', 'VILLE DE CLAMART'])
    end
  end

  context 'when the draft is saved by the applicant while Sirene does not answer' do
    subject(:refresh) { described_class.call(authorization_request: AuthorizationRequest.find(authorization_request.id)) }

    before do
      organization.update!(insee_payload: nil, insee_consecutive_failures: 0)
      authorization_request.tap { |request| request.data = request.data.merge('identity_source' => 'sirene_pending') }.save!(validate: false)
      mock_insee_authentication
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return do
        save_website_from_another_request
        { status: 503 }
      end
    end

    it 'keeps what the applicant saved meanwhile, and says Sirene did not answer' do
      refresh

      expect(authorization_request.reload.values_at(:wallet_website_url, :identity_source)).to eq(['https://www.clamart.fr', 'sirene_unavailable'])
    end
  end

  context 'when Sirene does not answer' do
    before do
      mock_insee_authentication
      stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 503)
    end

    it 'keeps the copy of the request and says so' do
      expect { expect(refresh).to be_failure }.not_to change { authorization_request.reload.data }
    end
  end
end
