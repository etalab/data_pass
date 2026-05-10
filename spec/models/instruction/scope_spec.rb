require 'rails_helper'

RSpec.describe Instruction::Scope do
  describe '#label' do
    context 'with a definition scope' do
      it 'returns the authorization definition name' do
        expect(described_class.new('dinum:api_entreprise').label)
          .to eq(AuthorizationDefinition.find('api_entreprise').name)
      end
    end

    context 'with an FD-wildcard scope' do
      it 'returns the provider name interpolated in the wildcard label' do
        expect(described_class.new('dinum:*').label).to eq('Tous les services DINUM')
      end
    end

    context 'with a blank or malformed scope' do
      it 'returns the raw string when empty' do
        expect(described_class.new('').label).to eq('')
      end

      it 'returns the raw string when missing the definition_id' do
        expect(described_class.new('dinum').label).to eq('dinum')
      end
    end
  end

  describe '#provider_name' do
    it 'returns the data provider name when the slug exists' do
      expect(described_class.new('dinum:api_entreprise').provider_name).to eq('DINUM')
    end

    it 'falls back to the upcased slug when the data provider is missing' do
      expect(described_class.new('unknown:something').provider_name).to eq('UNKNOWN')
    end
  end

  describe '#fd_wildcard?' do
    it 'is true when the definition_id is *' do
      expect(described_class.new('dinum:*')).to be_fd_wildcard
    end

    it 'is false when the definition_id is a definition' do
      expect(described_class.new('dinum:api_entreprise')).not_to be_fd_wildcard
    end
  end
end
