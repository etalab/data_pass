RSpec.describe FeatureFlag do
  describe '.enabled?' do
    context 'when the flag is unknown' do
      it 'returns true' do
        expect(described_class.enabled?(:unknown_flag)).to be true
      end
    end

    context 'when the flag is proconnect_dirigeant' do
      context 'when the environment is production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        end

        it 'is closed by default' do
          expect(described_class.enabled?(:proconnect_dirigeant)).to be false
        end

        it 'opens with its setting' do
          Setting.set(:proconnect_dirigeant_open, 'true')

          expect(described_class.enabled?(:proconnect_dirigeant)).to be true
        end
      end

      context 'when the environment is not production' do
        it 'is open without its setting' do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))

          expect(described_class.enabled?(:proconnect_dirigeant)).to be true
        end
      end
    end

    context 'when the flag is depot_dossier_mariage' do
      context 'when the environment is production' do
        it 'returns false' do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

          expect(described_class.enabled?(:depot_dossier_mariage)).to be false
        end
      end

      context 'when the environment is not production' do
        it 'returns true' do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))

          expect(described_class.enabled?(:depot_dossier_mariage)).to be true
        end
      end
    end

    context 'when the flag is registre_wallet' do
      it 'is disabled in production' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

        expect(described_class.enabled?(:registre_wallet)).to be false
      end

      it 'is enabled on sandbox' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('sandbox'))

        expect(described_class.enabled?(:registre_wallet)).to be true
      end

      it 'opens in production with the setting of the public wallet pages' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        Setting.set(:european_wallet_registry_open, 'true')

        expect(described_class.enabled?(:registre_wallet)).to be true
      end
    end

    context 'when the flag is given as a string' do
      it 'resolves it as a symbol' do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

        expect(described_class.enabled?('depot_dossier_mariage')).to be false
      end
    end

    context 'when the flag is authorization_definitions' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      context 'when the user is an admin' do
        it 'returns true' do
          user = instance_double(User, admin?: true)

          expect(described_class.enabled?(:authorization_definitions, user:)).to be true
        end
      end

      context 'when the user is not an admin' do
        it 'returns false' do
          user = instance_double(User, admin?: false)

          expect(described_class.enabled?(:authorization_definitions, user:)).to be false
        end
      end

      context 'when no user is given' do
        it 'returns false' do
          expect(described_class.enabled?(:authorization_definitions)).to be false
        end
      end

      context 'when the environment is test' do
        it 'returns true regardless of the user' do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))

          expect(described_class.enabled?(:authorization_definitions)).to be true
        end
      end
    end

    context 'when the flag is european_wallet_registry_open' do
      before { Setting.invalidate_cache! }

      it 'follows the european_wallet_registry_open setting' do
        Setting.set(:european_wallet_registry_open, 'true')

        expect(described_class.enabled?(:european_wallet_registry_open)).to be true
      end

      it 'stays closed without the setting' do
        expect(described_class.enabled?(:european_wallet_registry_open)).to be false
      end

      it 'stays closed when the setting is false' do
        Setting.set(:european_wallet_registry_open, 'false')

        expect(described_class.enabled?(:european_wallet_registry_open)).to be false
      end
    end
  end
end
