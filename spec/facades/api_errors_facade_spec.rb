RSpec.describe APIErrorsFacade, type: :facade do
  describe '.from_interactor_result' do
    subject(:api_error) { described_class.from_interactor_result(result) }

    let(:result) { Interactor::Context.build(error: error) }

    context 'with a simple error key' do
      let(:error) { { key: :form_not_found, errors: [] } }

      it 'uses the definition HTTP status' do
        expect(api_error.status).to eq(422)
      end

      it 'renders a single JSON:API error from the locale' do
        expect(api_error.errors).to eq([
          {
            status: '422',
            title: 'Formulaire introuvable',
            detail: 'Le formulaire demandé est introuvable.'
          }
        ])
      end
    end

    context 'with unauthorized_type' do
      let(:error) { { key: :unauthorized_type, errors: [] } }

      it 'uses the 403 status from the definition' do
        expect(api_error.status).to eq(403)
      end

      it 'exposes the localized title and detail' do
        expect(api_error.errors.first).to include(
          status: '403',
          title: 'Non autorisé'
        )
      end
    end

    context 'with invalid_data_keys' do
      let(:error) { { key: :invalid_data_keys, errors: %w[foo bar], format: :data_keys } }

      it 'renders one JSON:API error per invalid key' do
        expect(api_error.errors.size).to eq(2)
      end

      it 'interpolates the key into the localized detail' do
        expect(api_error.errors.first[:detail]).to include('foo')
      end

      it 'exposes a JSON:API source pointer per key' do
        pointers = api_error.errors.map { |e| e[:source][:pointer] }

        expect(pointers).to eq(['/data/foo', '/data/bar'])
      end
    end

    context 'with a messages-format error' do
      let(:error) do
        { key: :applicant_invalid, errors: ['Email est invalide', 'Prénom est obligatoire'] }
      end

      it 'renders one JSON:API error per message' do
        expect(api_error.errors.size).to eq(2)
      end

      it 'uses each message as the detail and the shared localized title' do
        expect(api_error.errors).to eq([
          { status: '422', title: 'Demandeur invalide', detail: 'Email est invalide' },
          { status: '422', title: 'Demandeur invalide', detail: 'Prénom est obligatoire' }
        ])
      end
    end

    context 'with an unknown key' do
      let(:error) { { key: :this_does_not_exist, errors: [] } }

      it 'falls back to the generic 422' do
        expect(api_error.status).to eq(422)
      end

      it 'uses the api_errors.generic translation' do
        expect(api_error.errors.first).to include(
          status: '422',
          title: 'Entité non traitable'
        )
      end
    end

    context 'without any error on the context' do
      let(:error) { nil }

      it 'falls back to the generic 422' do
        expect(api_error.status).to eq(422)
      end

      it 'exposes a single generic error' do
        expect(api_error.errors.size).to eq(1)
      end
    end
  end
end
