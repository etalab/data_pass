require 'rails_helper'

RSpec.describe ParsedRole do
  describe '.parse' do
    it 'parses a 3-part role string' do
      parsed = described_class.parse('dinum:api_entreprise:instructor')

      expect(parsed.provider_slug).to eq('dinum')
      expect(parsed.definition_id).to eq('api_entreprise')
      expect(parsed.role).to eq('instructor')
    end

    it 'parses admin role' do
      parsed = described_class.parse('admin')

      expect(parsed.admin?).to be true
      expect(parsed.provider_slug).to be_nil
    end

    it 'parses FD-level wildcard' do
      parsed = described_class.parse('dgfip:*:instructor')

      expect(parsed.fd_level?).to be true
      expect(parsed.provider_slug).to eq('dgfip')
      expect(parsed.role).to eq('instructor')
    end

    it 'returns null object for invalid format' do
      parsed = described_class.parse('bad_format')

      expect(parsed.role).to be_nil
      expect(parsed.definition_id).to be_nil
      expect(parsed.fd_level?).to be false
      expect(parsed.admin?).to be false
    end
  end

  describe '.valid?' do
    it 'accepts admin' do
      expect(described_class.valid?('admin')).to be true
    end

    it 'accepts valid 3-part role' do
      expect(described_class.valid?('dinum:api_entreprise:instructor')).to be true
    end

    it 'accepts FD-level wildcard' do
      expect(described_class.valid?('dinum:*:instructor')).to be true
    end

    it 'rejects invalid role type' do
      expect(described_class.valid?('dinum:api_entreprise:invalid')).to be false
    end

    it 'rejects unknown provider' do
      expect(described_class.valid?('unknown_provider:api_entreprise:instructor')).to be false
    end

    it 'rejects unknown definition' do
      expect(described_class.valid?('dinum:unknown_def:instructor')).to be false
    end

    it 'rejects definition with wrong provider' do
      expect(described_class.valid?('dgfip:api_entreprise:instructor')).to be false
    end

    it 'rejects 2-part format' do
      expect(described_class.valid?('api_entreprise:instructor')).to be false
    end
  end

  describe '.resolve_provider_slug' do
    it 'returns provider slug for known definition' do
      expect(described_class.resolve_provider_slug('api_entreprise')).to eq('dinum')
    end

    it 'returns nil for unknown definition' do
      expect(described_class.resolve_provider_slug('unknown')).to be_nil
    end
  end

  describe '#valid_definition?' do
    it 'returns true for valid definition-level role' do
      parsed = described_class.parse('dinum:api_entreprise:instructor')

      expect(parsed.valid_definition?).to be true
    end

    it 'returns false for wrong provider' do
      parsed = described_class.parse('dgfip:api_entreprise:instructor')

      expect(parsed.valid_definition?).to be false
    end

    it 'returns true for FD-level wildcard with known provider' do
      parsed = described_class.parse('dinum:*:instructor')

      expect(parsed.valid_definition?).to be true
    end

    it 'returns false for FD-level wildcard with unknown provider' do
      parsed = described_class.parse('unknown:*:instructor')

      expect(parsed.valid_definition?).to be false
    end
  end
end
