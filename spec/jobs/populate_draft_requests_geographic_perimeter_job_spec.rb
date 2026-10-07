RSpec.describe PopulateDraftRequestsGeographicPerimeterJob do
  subject(:populate_draft_requests_geographic_perimeter_job) { described_class.perform_now(organization.id) }

  let(:habilitation_type) do
    create(:habilitation_type,
      blocks: [{ 'name' => 'cnous_data_extraction_criteria' }, { 'name' => 'contacts' }],
      contact_types: ['contact_metier'])
  end
  let(:klass) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }
  let(:organization) { create(:organization) }

  def build_cnous_request(state:)
    klass.new(organization:, applicant: create(:user), form_uid: habilitation_type.uid, state:).tap do |request|
      request.save(validate: false)
    end
  end

  def insee_payload_for_commune(commune)
    {
      'etablissement' => {
        'uniteLegale' => { 'categorieJuridiqueUniteLegale' => '7210' },
        'adresseEtablissement' => { 'codeCommuneEtablissement' => commune },
      }
    }
  end

  context 'with a draft request created before the INSEE payload arrived' do
    let!(:draft_request) { build_cnous_request(state: 'draft') }

    before { organization.update!(insee_payload: insee_payload_for_commune('92023')) }

    it 'populates the geographic perimeter' do
      populate_draft_requests_geographic_perimeter_job

      expect(draft_request.reload.data).to include('entity_type' => 'commune', 'code_insee_entity' => '92023')
    end
  end

  context 'with a request that is no longer a draft' do
    let!(:submitted_request) { build_cnous_request(state: 'submitted') }

    before { organization.update!(insee_payload: insee_payload_for_commune('92023')) }

    it 'leaves it untouched' do
      populate_draft_requests_geographic_perimeter_job

      expect(submitted_request.reload.data).not_to include('entity_type')
    end
  end

  context 'with a draft request that does not carry the CNOUS block' do
    let!(:other_request) { create(:authorization_request, :api_entreprise, organization:) }

    before { organization.update!(insee_payload: insee_payload_for_commune('92023')) }

    it 'leaves it untouched' do
      populate_draft_requests_geographic_perimeter_job

      expect(other_request.reload.data).not_to include('entity_type')
    end
  end

  context 'with an organization that no longer exists' do
    subject(:populate_draft_requests_geographic_perimeter_job) { described_class.perform_now(0) }

    it 'does not raise' do
      expect { populate_draft_requests_geographic_perimeter_job }.not_to raise_error
    end
  end
end
