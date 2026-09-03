require 'rails_helper'

RSpec.describe Webhook do
  it 'has a valid factory' do
    expect(build(:webhook)).to be_valid
  end

  describe '#reset_failure_alert!' do
    it 'clears last_failure_alert_sent_at so a later outage can alert again' do
      webhook = create(:webhook, last_failure_alert_sent_at: 10.minutes.ago)

      expect { webhook.reset_failure_alert! }.to change { webhook.reload.last_failure_alert_sent_at }.to(nil)
    end

    it 'does not touch the record when no alert was sent' do
      webhook = create(:webhook, last_failure_alert_sent_at: nil)

      expect { webhook.reset_failure_alert! }.not_to(change { webhook.reload.updated_at })
    end
  end

  describe '#failure_alert_throttled?' do
    let(:webhook) { build(:webhook, last_failure_alert_sent_at:) }
    let(:window) { 2.hours }

    context 'when no alert has been sent yet' do
      let(:last_failure_alert_sent_at) { nil }

      it 'is not throttled' do
        expect(webhook.failure_alert_throttled?(window)).to be(false)
      end
    end

    context 'when an alert was sent within the window' do
      let(:last_failure_alert_sent_at) { 1.hour.ago }

      it 'is throttled' do
        expect(webhook.failure_alert_throttled?(window)).to be(true)
      end
    end

    context 'when an alert was sent outside the window' do
      let(:last_failure_alert_sent_at) { 3.hours.ago }

      it 'is not throttled' do
        expect(webhook.failure_alert_throttled?(window)).to be(false)
      end
    end
  end
end
