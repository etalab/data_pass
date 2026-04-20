require 'rails_helper'

RSpec.describe RoleSet do
  describe '#covers?' do
    it 'returns true when user has the exact role for the definition' do
      role_set = described_class.new(%w[api_entreprise:instructor], :instructor)

      expect(role_set.covers?('api_entreprise')).to be true
    end

    it 'returns false when user does not have the role for the definition' do
      role_set = described_class.new(%w[api_entreprise:instructor], :instructor)

      expect(role_set.covers?('api_particulier')).to be false
    end

    it 'returns true when user has a qualifying role via hierarchy' do
      role_set = described_class.new(%w[api_entreprise:manager], :instructor)

      expect(role_set.covers?('api_entreprise')).to be true
    end

    it 'returns false when role does not qualify via hierarchy' do
      role_set = described_class.new(%w[api_entreprise:reporter], :instructor)

      expect(role_set.covers?('api_entreprise')).to be false
    end

    context 'without definition_id' do
      it 'returns true when user has any qualifying role' do
        role_set = described_class.new(%w[api_entreprise:manager], :instructor)

        expect(role_set.covers?).to be true
      end

      it 'returns false when user has no qualifying role' do
        role_set = described_class.new(%w[api_entreprise:reporter], :instructor)

        expect(role_set.covers?).to be false
      end
    end
  end

  describe '#any?' do
    it 'returns true when matching roles exist' do
      role_set = described_class.new(%w[api_entreprise:instructor], :instructor)

      expect(role_set.any?).to be true
    end

    it 'returns false when no matching roles exist' do
      role_set = described_class.new(%w[], :instructor)

      expect(role_set.any?).to be false
    end
  end

  describe '#definition_ids' do
    it 'returns unique definition ids for matching roles' do
      role_set = described_class.new(
        %w[api_entreprise:instructor api_particulier:manager api_entreprise:manager],
        :instructor,
      )

      expect(role_set.definition_ids).to match_array(%w[api_entreprise api_particulier])
    end

    it 'includes roles from hierarchy' do
      role_set = described_class.new(
        %w[api_entreprise:reporter api_particulier:instructor api_entreprise:manager],
        :reporter,
      )

      expect(role_set.definition_ids).to match_array(%w[api_entreprise api_particulier])
    end
  end

  describe '#authorization_request_types' do
    it 'returns classified authorization request types' do
      role_set = described_class.new(%w[api_entreprise:instructor], :instructor)

      expect(role_set.authorization_request_types).to eq(["AuthorizationRequest::#{'api_entreprise'.classify}"])
    end
  end

  describe '#authorization_definitions' do
    it 'returns authorization definitions for matching roles' do
      role_set = described_class.new(%w[api_entreprise:instructor], :instructor)

      result = role_set.authorization_definitions

      expect(result.map(&:id)).to include('api_entreprise')
    end

    it 'skips unknown definitions' do
      role_set = described_class.new(%w[unknown_definition:instructor], :instructor)

      expect(role_set.authorization_definitions).to be_empty
    end
  end

  it 'ignores admin role' do
    role_set = described_class.new(%w[admin api_entreprise:instructor], :instructor)

    expect(role_set.definition_ids).to eq(%w[api_entreprise])
  end

  it 'ignores malformed roles' do
    role_set = described_class.new(%w[bad_format api_entreprise:instructor:extra], :instructor)

    expect(role_set.definition_ids).to eq([])
  end
end
