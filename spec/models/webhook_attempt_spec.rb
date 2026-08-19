require 'rails_helper'

RSpec.describe WebhookAttempt do
  it 'has a valid factory' do
    expect(build(:webhook_attempt)).to be_valid
  end

  describe '#abandoned?' do
    it 'is true when abandoned_at is present' do
      webhook_attempt = build(:webhook_attempt, :abandoned)

      expect(webhook_attempt.abandoned?).to be(true)
    end

    it 'is false when abandoned_at is nil' do
      webhook_attempt = build(:webhook_attempt, abandoned_at: nil)

      expect(webhook_attempt.abandoned?).to be(false)
    end
  end

  describe '.abandoned' do
    it 'returns only webhook attempts with an abandoned_at set' do
      abandoned_attempt = create(:webhook_attempt, :abandoned)
      create(:webhook_attempt, abandoned_at: nil)

      expect(described_class.abandoned).to contain_exactly(abandoned_attempt)
    end
  end
end
