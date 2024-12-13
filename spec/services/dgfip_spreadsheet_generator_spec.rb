RSpec.describe DGFIPSpreadsheetGenerator, type: :service do
  subject { described_class.new(authorization_requests).perform }

  let(:authorization_requests) do
    [
      create(:authorization_request, :api_impot_particulier, organization:, fill_all_attributes: true),
      create(:authorization_request, :api_impot_particulier, organization:, raw_attributes_from_v1: File.read('spec/fixtures/api_impot_particulier_v1_attributes.json'))
    ]
  end
  let(:organization) { create(:organization, siret: '21920023500014') }

  it 'works' do
    expect {
      subject
    }.not_to raise_error
  end

  describe 'data' do
    subject(:sheet_as_csv) do
      file.binmode
      file.write(described_class.new(authorization_requests).perform.to_stream.read)
      file.rewind
      # FileUtils.cp(file.path, 'tmp/dgfip_spreadsheet.xlsx')
      CSV.new(Roo::Spreadsheet.open(file.path, extension: :xlsx).sheet('DataPass Habilitations').to_csv, headers: true)
    end

    let(:file) { Tempfile.open('spreadsheet') }

    after do
      file.unlink
    end

    it 'has headers' do
      expect(sheet_as_csv.first.to_h.keys).to include('id', 'siret')
    end

    it 'has all rows' do
      expect(sheet_as_csv.count).to eq(2)
    end

    describe 'first line, built from v2 attributes' do
      subject(:v2_data) { sheet_as_csv.first.to_h }

      it 'has valid data' do
        expect(v2_data['target_api']).to eq('api_impot_particulier_production')
        expect(v2_data['demarche']).to eq('activites_periscolaires')
        expect(v2_data['nom_raison_sociale']).to eq('COMMUNE DE CLAMART')

        expect(JSON.parse(v2_data['additional_content'])).to include('acces_etat_civil' => true)
        expect(JSON.parse(v2_data['insee_payload'])).to be_present
      end
    end

    describe 'second line, legacy data' do
      subject(:legacy_data) do
        sheet_as_csv.to_a[1].to_h
      end

      it 'has valid data' do
        initial_data = JSON.parse(File.read('spec/fixtures/api_impot_particulier_v1_attributes.json'))

        expect(JSON.parse(legacy_data['insee_payload'])).to be_present

        legacy_data.each do |key, value|
          next if key == 'insee_payload'

          if key == 'additional_content'
            expect(JSON.parse(value)).to eq(initial_data[key])
          elsif initial_data[key].nil?
            expect(value).to be_nil
          else
            expect(value.to_s).to eq(initial_data[key].to_s)
          end
        end
      end
    end
  end
end
