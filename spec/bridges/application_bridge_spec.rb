RSpec.describe ApplicationBridge, type: :job do
  subject(:dummy_bridge) { job_instance.perform_now }

  before(:all) do
    class DummyBridge < ApplicationBridge
      def on_approve; end
    end
  end

  let(:job_instance) { DummyBridge.new(authorization_request, 'approve') }
  let(:authorization_request) { create(:authorization_request) }

  describe 'error tracking' do
    before do
      allow(job_instance).to receive(:on_approve).and_raise(StandardError)
      allow(job_instance).to receive(:attempts).and_return(attempts)
    end

    describe 'when the attempt count has not reached the threshold yet' do
      let(:attempts) { ApplicationBridge::THRESHOLD_TO_TRACK_ERROR - 1 }

      it 'does not track the error' do
        expect(Sentry).not_to receive(:capture_exception)

        dummy_bridge
      end
    end

    describe 'when the attempt count has reached the threshold' do
      let(:attempts) { ApplicationBridge::THRESHOLD_TO_TRACK_ERROR }

      it 'tracks the error' do
        expect(Sentry).to receive(:capture_exception)

        dummy_bridge
      end
    end
  end
end
