require 'rails_helper'

RSpec.describe AdminTooling::ImportEligibilityRules do
  let(:csv_content) do
    <<~CSV
      Nom API,ID Datapass,ID API,Public Cible,Eligible,phrase,CTA,Texte du CTA,Notes
      API Particulier,api-particulier,107959582842083703515711757520394806672,particulier,Non,"Vous n'êtes pas autorisé à accéder aux données de cette API. L'usage de l'API Particulier est <strong>uniquement reservé aux acteurs publics</strong>",,,
      API Particulier,api-particulier,107959582842083703515711757520394806672,collectivité ou administration,Oui,"Que vous soyez une collectivité, une administration centrale... vous êtes éligible",https://datapass.api.gouv.fr/api-particulier,Demander une habilitation API Particulier,
      API Particulier,api-particulier,107959582842083703515711757520394806672,entreprise ou association,Non,"Vous n'êtes pas autorisé à accéder aux données de cette API.",,,
      API Entreprise,api-entreprise,227114281190751739760356458553733252313,particulier,Non,"Vous n'êtes pas autorisé à accéder aux données de cette API. L'usage de l'API Entreprise est uniquement reservé aux acteurs publics",,,
      API Entreprise,api-entreprise,227114281190751739760356458553733252313,collectivité ou administration,Oui,"En tant qu'administration, vous êtes éligible",https://datapass.api.gouv.fr/api-entreprise,Demander l'accès aux données,
      API Entreprise,api-entreprise,227114281190751739760356458553733252313,entreprise ou association,Peut-être,"Sous certaines conditions, vous pourriez être éligible",https://datapass.api.gouv.fr/en-savoir-plus,En savoir plus,
    CSV
  end

  let(:csv_url) { 'https://example.com/eligibility.csv' }
  let(:output_file) { Tempfile.new(['eligibility_rules', '.yml']) }

  before do
    stub_request(:get, csv_url).to_return(body: csv_content, status: 200)
  end

  after do
    output_file.close
    output_file.unlink
  end

  describe '.call' do
    it 'fetches CSV from the provided URL' do
      described_class.call(csv_url, output_path: output_file.path)
      expect(WebMock).to have_requested(:get, csv_url)
    end

    it 'generates YAML file with correct structure' do
      described_class.call(csv_url, output_path: output_file.path)

      expect(File.exist?(output_file.path)).to be true
      yaml_data = YAML.load_file(output_file.path)

      expect(yaml_data).to be_an(Array)
      expect(yaml_data.size).to eq(2)
    end

    it 'correctly maps CSV data to YAML structure' do
      described_class.call(csv_url, output_path: output_file.path)
      yaml_data = YAML.load_file(output_file.path)

      first_rule = yaml_data.first
      expect(first_rule['id']).to eq(1)
      expect(first_rule['definition_id']).to eq('api_particulier')
      expect(first_rule['options']).to be_an(Array)
      expect(first_rule['options'].size).to eq(3)
    end

    it 'normalizes type attribute' do
      described_class.call(csv_url, output_path: output_file.path)
      yaml_data = YAML.load_file(output_file.path)

      option = yaml_data.first['options'].first
      expect(option['type']).to eq('particulier')
    end

    it 'normalizes eligible attribute' do
      described_class.call(csv_url, output_path: output_file.path)
      yaml_data = YAML.load_file(output_file.path)

      particulier_option = yaml_data.first['options'].find { |opt| opt['type'] == 'particulier' }
      collectivite_option = yaml_data.first['options'].find { |opt| opt['type'] == 'collectivite_ou_administration' }
      entreprise_option = yaml_data.last['options'].find { |opt| opt['type'] == 'entreprise_ou_association' }

      expect(particulier_option['eligible']).to eq('no')
      expect(collectivite_option['eligible']).to eq('yes')
      expect(entreprise_option['eligible']).to eq('maybe')
    end

    it 'includes body from phrase column' do
      described_class.call(csv_url, output_path: output_file.path)
      yaml_data = YAML.load_file(output_file.path)

      option = yaml_data.first['options'].first
      expect(option['body']).to include('uniquement reservé aux acteurs publics')
    end

    it 'omits cta attribute when CTA column is empty' do
      described_class.call(csv_url, output_path: output_file.path)
      yaml_data = YAML.load_file(output_file.path)

      particulier_option = yaml_data.first['options'].find { |opt| opt['type'] == 'particulier' }
      expect(particulier_option).not_to have_key('cta')
    end

    it 'includes cta with content and url when CTA and Texte du CTA columns have values' do
      described_class.call(csv_url, output_path: output_file.path)
      yaml_data = YAML.load_file(output_file.path)

      collectivite_option = yaml_data.first['options'].find { |opt| opt['type'] == 'collectivite_ou_administration' }
      expect(collectivite_option['cta']).to eq({ 'content' => 'Demander une habilitation API Particulier', 'url' => 'https://datapass.api.gouv.fr/api-particulier' })
    end

    it 'returns hash with imported and skipped API lists' do
      result = described_class.call(csv_url, output_path: output_file.path)

      expect(result).to be_a(Hash)
      expect(result[:imported]).to eq(%w[api-particulier api-entreprise])
      expect(result[:skipped]).to eq([])
    end

    context 'when API has incomplete target audiences' do
      let(:csv_content) do
        <<~CSV
          Nom API,ID Datapass,ID API,Public Cible,Eligible,phrase,CTA,Texte du CTA,Notes
          API Complete,api-complete,123,particulier,Non,"Test",,,
          API Complete,api-complete,123,collectivité ou administration,Oui,"Test",https://example.com,CTA text,
          API Complete,api-complete,123,entreprise ou association,Non,"Test",,,
          API Incomplete,api-incomplete,456,particulier,Non,"Test",,,
          API Incomplete,api-incomplete,456,collectivité ou administration,Oui,"Test",https://example.com,CTA text,
        CSV
      end

      it 'skips APIs without all 3 target audiences' do
        result = described_class.call(csv_url, output_path: output_file.path)

        expect(result[:imported]).to eq(['api-complete'])
        expect(result[:skipped]).to eq(['api-incomplete'])

        yaml_data = YAML.load_file(output_file.path)
        expect(yaml_data.size).to eq(1)
        expect(yaml_data.first['definition_id']).to eq('api_complete')
      end
    end

    context 'when rows have empty ID Datapass' do
      let(:csv_content) do
        <<~CSV
          Nom API,ID Datapass,ID API,Public Cible,Eligible,phrase,CTA,Texte du CTA,Notes
          ,,,particulier,Non,"Should be skipped",,,
          API Valid,api-valid,123,particulier,Non,"Test",,,
          API Valid,api-valid,123,collectivité ou administration,Oui,"Test",https://example.com,CTA,
          API Valid,api-valid,123,entreprise ou association,Non,"Test",,,
        CSV
      end

      it 'skips rows with empty ID Datapass' do
        result = described_class.call(csv_url, output_path: output_file.path)

        expect(result[:imported]).to eq(['api-valid'])
        yaml_data = YAML.load_file(output_file.path)
        expect(yaml_data.size).to eq(1)
      end
    end

    context 'when import is run multiple times' do
      it 'is idempotent' do
        result1 = described_class.call(csv_url, output_path: output_file.path)
        result2 = described_class.call(csv_url, output_path: output_file.path)

        expect(result1).to eq(result2)

        yaml_data = YAML.load_file(output_file.path)
        expect(yaml_data.size).to eq(2)
      end
    end
  end
end
