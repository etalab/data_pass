RSpec.describe FeatureFlag do
  describe '.enabled?' do
    context 'when the flag is unknown' do
      it 'returns true' do
        expect(described_class.enabled?(:unknown_flag)).to be true
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
  end
end
