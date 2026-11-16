RSpec.describe ValidateAPIDocumentValues do
  describe '#call' do
    subject(:result) do
      described_class.call(
        authorization_request_params: ActionController::Parameters.new(params),
        authorization_request_form: authorization_request_form
      )
    end

    let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise') }
    let(:pdf) { Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf') }

    context 'without any document key' do
      let(:params) { { 'intitule' => 'Mon projet' } }

      it { is_expected.to be_a_success }
    end

    context 'with uploaded files on a multiple document key' do
      let(:params) { { 'maquette_projet' => [pdf, pdf] } }

      it { is_expected.to be_a_success }
    end

    context 'with blank values' do
      [nil, '', [], [''], [nil]].each do |blank_value|
        context "with #{blank_value.inspect}" do
          let(:params) { { 'maquette_projet' => blank_value } }

          it { is_expected.to be_a_success }
        end
      end
    end

    context 'with a string' do
      let(:params) { { 'maquette_projet' => 'JVBERi0xLjQK' } }

      it { is_expected.to be_a_failure }

      it 'fails with invalid_document_values and exposes the key' do
        expect(result.error).to include(
          key: :invalid_document_values,
          errors: ['maquette_projet'],
          format: :data_keys
        )
      end
    end

    context 'with an array of strings' do
      let(:params) { { 'maquette_projet' => ['JVBERi0xLjQK'] } }

      it { is_expected.to be_a_failure }
    end

    context 'with a file mixed with a string' do
      let(:params) { { 'maquette_projet' => [pdf, 'JVBERi0xLjQK'] } }

      it { is_expected.to be_a_failure }
    end

    context 'with a hash' do
      let(:params) { { 'maquette_projet' => { 'io' => 'x' } } }

      it { is_expected.to be_a_failure }
    end

    context 'with several offending document keys' do
      let(:params) do
        { 'maquette_projet' => 'abc', 'cadre_juridique_document' => ['def'], 'intitule' => 'ok' }
      end

      it 'lists each offending key once' do
        expect(result.error[:errors]).to contain_exactly('maquette_projet', 'cadre_juridique_document')
      end
    end
  end
end
