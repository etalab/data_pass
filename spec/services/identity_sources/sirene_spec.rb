RSpec.describe IdentitySources::Sirene do
  subject(:source) { described_class.new }

  let(:organization) { create(:organization, siret:) }

  describe '#attributes' do
    subject(:attributes) { source.attributes(organization) }

    context 'with a municipality' do
      let(:siret) { '21920023500014' }

      it 'gives the identity read from the INSEE data' do
        expect(attributes).to include(
          source: 'sirene',
          siret: '21920023500014',
          legal_name: 'COMMUNE DE CLAMART',
          legal_form: 'Commune et commune nouvelle',
          public_sector: 'true'
        )
      end

      it 'gives the address on one line, written as on a letter' do
        expect(attributes[:address]).to eq('1 place Maurice Gunsbourg, 92140 Clamart')
      end
    end

    context 'with a non diffusible establishment' do
      let(:siret) { '12345678900015' }

      it 'gives no address' do
        expect(attributes.values_at(:source, :address)).to eq(['non_diffusible', nil])
      end
    end

    context 'without INSEE data yet' do
      let(:siret) { '21920023500022' }

      before { organization.update!(insee_payload: nil) }

      it 'says the identity is loading, with only the SIRET from the connection' do
        expect(attributes.compact).to eq(source: 'sirene_pending', siret: '21920023500022')
      end
    end

    context 'without INSEE data after a failed call' do
      let(:siret) { '21920023500022' }

      before { organization.update!(insee_payload: nil, insee_consecutive_failures: 1) }

      it 'says Sirene could not give the identity' do
        expect(attributes.compact).to eq(source: 'sirene_unavailable', siret: '21920023500022')
      end
    end
  end

  describe '#refresh' do
    let(:siret) { '21920023500022' }

    before do
      organization.update!(insee_payload: nil, last_insee_payload_updated_at: 2.days.ago)
      mock_insee_sirene_api_etablissement_valid(siret:, full: true)
    end

    it 'fetches the INSEE data of the organization right away' do
      source.refresh(organization)

      expect(organization.reload.insee_payload).to be_present
    end

    context 'when the INSEE data was read less than a day ago' do
      before { organization.update!(last_insee_payload_updated_at: 1.hour.ago) }

      it 'calls the INSEE anyway, since the applicant asked for it' do
        expect(source.refresh(organization)).to be(true)
        expect(organization.reload.insee_payload).to be_present
      end
    end

    context 'when the INSEE does not answer' do
      before do
        mock_insee_authentication
        stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 503)
      end

      it 'says nothing was refreshed' do
        expect(source.refresh(organization)).to be(false)
      end
    end
  end
end
