RSpec.describe Seeds do
  let(:seeds) { described_class.new }

  describe '#perform' do
    subject(:perform) { seeds.perform }

    before do
      seeds.flushdb
    end

    it 'does not raise error' do
      expect {
        perform
      }.not_to raise_error
    end

    it 'creates a dgfip user' do
      expect {
        perform
      }.to change(User.where(email: 'dgfip@yopmail.com'), :count).by(1)
    end

    context 'with the webhook attempts preview' do
      let(:webhook) { Webhook.find_by!(url: Seeds::PREVIEW_WEBHOOK_URL) }

      before { perform }

      it 'creates an active api_entreprise webhook' do
        expect(webhook).to have_attributes(
          authorization_definition_id: 'api_entreprise',
          enabled: true,
          validated: true
        )
      end

      it 'covers every visual state of the attempts list' do
        expect(webhook.attempts.successful.count).to eq(1)
        expect(webhook.attempts.failed.where(abandoned_at: nil).count).to eq(3)
        expect(webhook.attempts.abandoned.count).to eq(2)
        expect(webhook.attempts.where(status_code: nil).count).to eq(1)
      end
    end
  end

  describe '#flushdb' do
    subject(:flushdb) { seeds.flushdb }

    it 'does not raise error' do
      expect {
        flushdb
      }.not_to raise_error
    end

    context 'when in production' do
      before do
        allow(Rails).to receive(:env).and_return('production')
      end

      it 'raises error' do
        expect {
          flushdb
        }.to raise_error(StandardError)
      end
    end
  end
end
