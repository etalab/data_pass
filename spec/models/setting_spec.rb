RSpec.describe Setting do
  before { described_class.invalidate_cache! }

  describe '.fetch' do
    it 'reads the environment variable before the credentials' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('INSEE_PASSWORD').and_return('from_env')

      expect(described_class.fetch(:insee_password)).to eq('from_env')
    end

    it 'reads the credentials when neither the database nor the environment answers' do
      allow(Rails.application.credentials).to receive(:dig).with(:insee_password).and_return('from_credentials')

      expect(described_class.fetch(:insee_password)).to eq('from_credentials')
    end

    it 'reads the database before the environment' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('INSEE_PASSWORD').and_return('from_env')
      described_class.set(:insee_password, 'from_database')

      expect(described_class.fetch(:insee_password)).to eq('from_database')
    end

    it 'enables the INSEE calls by default' do
      expect(described_class.fetch(:insee_calls_enabled)).to be(true)
    end

    it 'disables the INSEE calls on the exact string false' do
      described_class.set(:insee_calls_enabled, 'false')

      expect(described_class.fetch(:insee_calls_enabled)).to be(false)
    end

    it 'keeps the INSEE calls enabled on anything else than the exact string false' do
      %w[FALSE False 0 off no nope true].each do |value|
        described_class.set(:insee_calls_enabled, value)

        expect(described_class.fetch(:insee_calls_enabled)).to be(true)
      end
    end

    it 'casts a duration setting' do
      described_class.set(:insee_calls_pause_duration, '3600')

      expect(described_class.fetch(:insee_calls_pause_duration)).to eq(1.hour)
    end

    it 'returns an empty list when no recipient is configured' do
      expect(described_class.fetch(:hubee_formulaire_qf_notification_emails)).to eq([])
    end

    it 'casts a comma separated list, whitespace included' do
      described_class.set(:hubee_formulaire_qf_notification_emails, 'support@hubee.example, relais@hubee.example')
      described_class.invalidate_cache!

      expect(described_class.fetch(:hubee_formulaire_qf_notification_emails)).to eq(%w[support@hubee.example relais@hubee.example])
    end

    it 'accepts an array and reads it back as a list' do
      described_class.set(:hubee_formulaire_qf_notification_emails, %w[support@hubee.example relais@hubee.example])
      described_class.invalidate_cache!

      expect(described_class.fetch(:hubee_formulaire_qf_notification_emails)).to eq(%w[support@hubee.example relais@hubee.example])
    end

    it 'casts a list coming from the credentials' do
      allow(Rails.application.credentials).to receive(:dig).with(:hubee_formulaire_qf_notification_emails).and_return(%w[support@hubee.example])

      expect(described_class.fetch(:hubee_formulaire_qf_notification_emails)).to eq(%w[support@hubee.example])
    end

    it 'raises on a key that is not declared in the code' do
      expect { described_class.fetch(:not_declared) }.to raise_error(described_class::UnknownKeyError)
    end
  end

  describe '.set' do
    it 'refuses a key that is not declared in the code' do
      expect { described_class.set(:not_declared, 'x') }.to raise_error(described_class::UnknownKeyError)
    end

    it 'replaces an existing override instead of creating a second row' do
      described_class.set(:insee_password, 'first')

      expect { described_class.set(:insee_password, 'second') }.not_to change(described_class, :count)
      expect(described_class.fetch(:insee_password)).to eq('second')
    end

    it 'stores the value encrypted at rest' do
      described_class.set(:insee_password, 'a_secret')

      stored = described_class.connection.select_value("SELECT value FROM settings WHERE key = 'insee_password'")

      expect(stored).not_to include('a_secret')
    end
  end

  describe '.unset' do
    it 'restores the fallback chain' do
      described_class.set(:insee_calls_enabled, 'false')
      described_class.unset(:insee_calls_enabled)

      expect(described_class.fetch(:insee_calls_enabled)).to be(true)
    end
  end

  describe '.overridden_keys' do
    it 'lists what the database actually overrides' do
      described_class.set(:insee_password, 'a_secret')

      expect(described_class.overridden_keys).to eq(%w[insee_password])
    end
  end

  describe 'protection of the stored values' do
    it 'keeps the value out of inspect, and therefore out of the logs' do
      described_class.set(:insee_password, 'a_secret')

      expect(described_class.find_by(key: 'insee_password').inspect).not_to include('a_secret')
    end

    it 'still reads the value through the model' do
      described_class.set(:insee_password, 'a_secret')

      expect(described_class.find_by(key: 'insee_password').value).to eq('a_secret')
    end
  end

  describe 'when the table is not there yet' do
    before do
      allow(described_class).to receive(:all) do
        raise PG::UndefinedTable, 'relation "settings" does not exist'
      rescue PG::UndefinedTable
        raise ActiveRecord::StatementInvalid, 'relation "settings" does not exist'
      end
    end

    it 'falls through to the rest of the chain instead of breaking' do
      allow(Rails.application.credentials).to receive(:dig).with(:insee_password).and_return('from_credentials')

      expect(described_class.fetch(:insee_password)).to eq('from_credentials')
    end

    it 'does not cache the failure' do
      described_class.fetch(:insee_password)
      allow(described_class).to receive(:all).and_call_original
      described_class.create!(key: 'insee_password', value: 'from_database')

      expect(described_class.fetch(:insee_password)).to eq('from_database')
    end
  end

  describe 'when the database answers with anything else than a missing table' do
    before do
      allow(described_class).to receive(:all).and_raise(ActiveRecord::StatementInvalid)
    end

    it 'raises instead of silently falling back to the rest of the chain' do
      expect { described_class.fetch(:insee_calls_enabled) }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe 'when a stored value cannot be decrypted' do
    let(:unreadable_setting) do
      instance_double(described_class, key: 'insee_password').tap do |setting|
        allow(setting).to receive(:value).and_raise(ActiveRecord::Encryption::Errors::Decryption)
      end
    end

    before do
      allow(described_class).to receive(:all).and_return([unreadable_setting])
      allow(Sentry).to receive(:capture_exception)
    end

    it 'ignores that row instead of breaking every key' do
      expect(described_class.fetch(:insee_calls_enabled)).to be(true)
    end

    it 'reports it to Sentry' do
      described_class.fetch(:insee_calls_enabled)

      expect(Sentry).to have_received(:capture_exception).with(
        an_instance_of(ActiveRecord::Encryption::Errors::Decryption),
        level: :warning,
      )
    end
  end

  describe 'cache invalidation across processes' do
    it 'picks up a value written by another process' do
      described_class.fetch(:insee_password)

      described_class.create!(key: 'insee_password', value: 'written_elsewhere')
      Kredis.counter(described_class::REDIS_CACHE_KEY).increment

      expect(described_class.fetch(:insee_password)).to eq('written_elsewhere')
    end
  end
end
