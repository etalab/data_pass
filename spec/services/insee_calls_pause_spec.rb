RSpec.describe INSEECallsPause do
  describe '.pause!' do
    it 'pauses the INSEE calls' do
      described_class.pause!

      expect(described_class).to be_paused
    end

    it 'pauses long enough to stay under the INSEE account lockout threshold' do
      described_class.pause!

      pause_ttl = Kredis.configured_for(:shared).ttl(described_class.flag.key)

      expect(pause_ttl).to be_within(1.minute).of(Setting.fetch(:insee_calls_pause_duration))
    end

    it 'accepts a custom duration' do
      described_class.pause!(duration: 42.minutes)

      pause_ttl = Kredis.configured_for(:shared).ttl(described_class.flag.key)

      expect(pause_ttl).to be_within(1.minute).of(42.minutes)
    end
  end

  describe 'when Redis is unreachable' do
    before do
      allow(Kredis).to receive(:flag).and_return(unreachable_flag)
      allow(Sentry).to receive(:capture_message)
    end

    let(:unreachable_flag) do
      instance_double(Kredis::Types::Flag).tap do |flag|
        allow(flag).to receive(:failsafe) { |returning:, &_block| returning }
      end
    end

    it 'considers the INSEE calls paused rather than letting them through' do
      expect(described_class).to be_paused
    end

    it 'reports that the circuit breaker could not be armed' do
      described_class.pause!

      expect(Sentry).to have_received(:capture_message).with(/unable to arm/, level: :error)
    end

    it 'tells the caller that the pause did not take' do
      expect(described_class.pause!).to be(false)
    end
  end

  describe '.record_skipped_call' do
    it 'counts the skipped calls without storing them' do
      2.times { described_class.record_skipped_call }

      expect(described_class.skipped_calls_count).to eq(2)
    end
  end

  describe '.reset!' do
    before do
      described_class.pause!
      described_class.record_skipped_call
    end

    it 'resumes the INSEE calls' do
      described_class.reset!

      expect(described_class).not_to be_paused
    end

    it 'resets the skipped calls counter' do
      described_class.reset!

      expect(described_class.skipped_calls_count).to eq(0)
    end
  end
end
