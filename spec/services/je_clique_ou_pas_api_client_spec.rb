RSpec.describe JeCliqueOuPasAPIClient do
  let(:file) { 'dummy_file' }
  let(:uuid) { 'dummy_uuid' }
  let(:token) { Rails.application.credentials.je_clique_ou_pas[:token] }

  describe '#analyze' do
    subject { described_class.new.analyze(file) }

    before do
      stub_request(:post, "#{Rails.application.credentials.je_clique_ou_pas[:host]}/submit")
        .with(body: { file: }, headers: { 'X-Auth-token' => token })
        .to_return(status:, body: response_body.to_json)
    end

    context 'when the request is successful' do
      let(:status) { 200 }
      let(:response_body) { { status: true, uuid: } }

      it 'returns the analysis uuid' do
        expect(subject).to eq(
          {
            uuid:,
            error: nil
          }
        )
      end
    end

    context 'when the request is not successful' do
      let(:status) { 400 }
      let(:response_body) { { status: false, error: 'invalid filetype' } }

      it 'returns the error' do
        expect(subject).to eq(
          {
            uuid: nil,
            error: 'invalid filetype'
          }
        )
      end
    end
  end

  describe '#result' do
    subject { described_class.new.result(uuid) }

    before do
      stub_request(:get, "#{Rails.application.credentials.je_clique_ou_pas[:host]}/results/#{uuid}")
        .with(headers: { 'X-Auth-token' => token })
        .to_return(status:, body: response_body.to_json)
    end

    context 'when the request is successful' do
      let(:status) { 200 }
      let(:response_body) do
        {
          status: true,
          is_malware: true,
          done: true,
          timestamp: 1_637_835_534_067
        }
      end

      it 'returns the analysis result' do
        expect(subject).to eq(
          {
            is_malware: true,
            analyzed_at: 1_637_835_534_067,
            error: nil
          }
        )
      end
    end

    context 'when the request is not successful' do
      let(:status) { 400 }
      let(:response_body) { { status: false, error: 'invalid filetype' } }

      it 'returns the error' do
        expect(subject).to eq(
          {
            is_malware: nil,
            analyzed_at: nil,
            error: 'invalid filetype'
          }
        )
      end
    end
  end
end
