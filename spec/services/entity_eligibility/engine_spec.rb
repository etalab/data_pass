RSpec.describe EntityEligibility::Engine do
  let(:organization) do
    build(:organization,
      legal_entity_registry: 'insee_sirene',
      legal_entity_id: '12345678900010',
      insee_payload: {
        'etablissement' => {
          'uniteLegale' => { 'categorieJuridiqueUniteLegale' => '7210' },
        },
      })
  end

  describe '#verdict' do
    subject(:verdict) do
      described_class.new(organization:, authorization_request_form:).verdict
    end

    context 'when a rule is defined for the use case' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('hubee-cert-dc') }

      it 'delegates to the matching rule' do
        expect(verdict).to be_eligible
      end
    end

    context 'when no rule is defined for the use case' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('hubee-dila') }

      it 'returns an unknown verdict' do
        expect(verdict).to be_unknown
      end
    end
  end

  describe '.from_request' do
    subject(:verdict) { described_class.from_request(authorization_request).verdict }

    let(:authorization_request) do
      AuthorizationRequest::HubEECertDC.new(form_uid: 'hubee-cert-dc', organization:)
    end

    it 'builds the engine from the demande' do
      expect(verdict).to be_eligible
    end
  end
end
