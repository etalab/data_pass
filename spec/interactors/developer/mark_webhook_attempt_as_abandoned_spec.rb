require 'rails_helper'

RSpec.describe Developer::MarkWebhookAttemptAsAbandoned, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(webhook_attempt: webhook_attempt) }

    let(:webhook_attempt) { create(:webhook_attempt, :failed) }

    it 'sets abandoned_at on the webhook attempt' do
      expect { result }.to change { webhook_attempt.reload.abandoned_at }.from(nil)
    end

    it { is_expected.to be_success }

    context 'when webhook_attempt is blank' do
      let(:webhook_attempt) { nil }

      it { is_expected.to be_success }

      it 'does not raise' do
        expect { result }.not_to raise_error
      end
    end
  end
end
