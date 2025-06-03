RSpec.describe JeCliqueOuPasAPIClient do
  let(:attachment) { create(:active_storage_attachment) }
  let(:token) { Rails.application.credentials.je_clique_ou_pas[:token] }

  describe '#analyze' do
    subject { described_class.new.analyze(attachment) }

    before do
      stub_request(:post, "#{Rails.application.credentials.je_clique_ou_pas[:host]}/submit")
        .to_return(status:, body: response_body.to_json)
    end

    context 'when the request is successful' do
      let(:status) { 200 }
      let(:response_body) { { status: true } }

      it 'returns no error' do
        expect(subject).to eq(
          { error: nil }
        )
      end
    end

    context 'when the request is not successful' do
      let(:status) { 400 }
      let(:response_body) { { error: 'Bad request' } }

      it 'returns the error' do
        expect(subject).to eq(
          { error: 'Bad request' }
        )
      end
    end
  end

  describe '#result' do
    subject { described_class.new.result('dummy_id_or_sha256') }

    before do
      stub_request(:get, "#{Rails.application.credentials.je_clique_ou_pas[:host]}/results/dummy_id_or_sha256")
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
      let(:response_body) { { error: 'Bad request' } }

      it 'returns the error' do
        expect(subject).to eq(
          {
            is_malware: nil,
            analyzed_at: nil,
            error: 'Bad request'
          }
        )
      end
    end
  end
end
