require 'rails_helper'

RSpec.describe Developer::NotifyWebhookFailure, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(webhook: webhook, throttle_window: throttle_window) }

    let(:webhook) { create(:webhook, :active) }
    let(:throttle_window) { 2.hours }

    it 'sends an alert email to the developers' do
      expect { result }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
        'WebhookMailer',
        'fail',
        'deliver_now',
        hash_including(params: hash_including(webhook: webhook))
      )
    end

    it 'sets last_failure_alert_sent_at on the webhook' do
      expect { result }.to change { webhook.reload.last_failure_alert_sent_at }.from(nil)
    end

    context 'when an alert was already sent within the throttle window' do
      before do
        webhook.update!(last_failure_alert_sent_at: 1.hour.ago)
      end

      it 'does not send a second email' do
        expect { result }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it 'does not update last_failure_alert_sent_at' do
        expect { result }.not_to(change { webhook.reload.last_failure_alert_sent_at })
      end
    end

    context 'when the previous alert falls outside the throttle window' do
      before do
        webhook.update!(last_failure_alert_sent_at: 3.hours.ago)
      end

      it 'sends a new email' do
        expect { result }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end

  describe 'concurrent calls on the same webhook', :concurrent do
    self.use_transactional_tests = false

    let(:webhook) { create(:webhook, :active) }
    let(:throttle_window) { 2.hours }

    after { webhook.destroy }

    it 'only claims the alert slot once' do
      barrier = Concurrent::CyclicBarrier.new(2)
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      threads = Array.new(2) do
        Thread.new do
          barrier.wait
          described_class.call(webhook: Webhook.find(webhook.id), throttle_window: throttle_window)
        ensure
          ActiveRecord::Base.connection_handler.clear_active_connections!
        end
      end

      threads.each(&:join)

      enqueued_mail_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |job| job[:job] == ActionMailer::MailDeliveryJob }
      expect(enqueued_mail_jobs.size).to eq(1)
      expect(webhook.reload.last_failure_alert_sent_at).to be_present
    end
  end
end
