require 'rails_helper'

RSpec.describe RoleSet do
  let(:user) { create(:user) }

  def grant(kind, definition_id)
    user.grant_role(kind, definition_id)
  end

  def grant_fd(kind, provider_slug)
    user.grant_fd_role(kind, provider_slug)
  end

  describe '#covers?' do
    it 'returns true when user has the exact role for the definition' do
      grant(:instructor, 'api_entreprise')

      expect(user.roles_for(:instructor).covers?('api_entreprise')).to be true
    end

    it 'returns false when user does not have the role for the definition' do
      grant(:instructor, 'api_entreprise')

      expect(user.roles_for(:instructor).covers?('api_particulier')).to be false
    end

    it 'returns true when user has a qualifying role via hierarchy' do
      grant(:manager, 'api_entreprise')

      expect(user.roles_for(:instructor).covers?('api_entreprise')).to be true
    end

    it 'returns false when role does not qualify via hierarchy' do
      grant(:reporter, 'api_entreprise')

      expect(user.roles_for(:instructor).covers?('api_entreprise')).to be false
    end

    it 'returns true with FD-level wildcard covering the definition' do
      grant_fd(:instructor, 'dinum')

      expect(user.roles_for(:instructor).covers?('api_entreprise')).to be true
    end

    it 'returns false with FD-level wildcard for wrong provider' do
      grant_fd(:instructor, 'dgfip')

      expect(user.roles_for(:instructor).covers?('api_entreprise')).to be false
    end

    context 'without definition_id' do
      it 'returns true when user has any qualifying role' do
        grant(:manager, 'api_entreprise')

        expect(user.roles_for(:instructor).covers?).to be true
      end

      it 'returns false when user has no qualifying role' do
        grant(:reporter, 'api_entreprise')

        expect(user.roles_for(:instructor).covers?).to be false
      end
    end
  end

  describe '#any?' do
    it 'returns true when matching roles exist' do
      grant(:instructor, 'api_entreprise')

      expect(user.roles_for(:instructor).any?).to be true
    end

    it 'returns false when no matching roles exist' do
      expect(user.roles_for(:instructor).any?).to be false
    end
  end

  describe '#definition_ids' do
    it 'returns unique definition ids for matching roles' do
      grant(:instructor, 'api_entreprise')
      grant(:manager, 'api_particulier')

      expect(user.roles_for(:instructor).definition_ids).to match_array(%w[api_entreprise api_particulier])
    end

    it 'expands FD-level wildcard to all definitions under the provider' do
      grant_fd(:instructor, 'dinum')

      dinum_definition_ids = AuthorizationDefinition.all
        .select { |ad| ad.provider_slug == 'dinum' }
        .map(&:id)

      expect(user.roles_for(:instructor).definition_ids).to match_array(dinum_definition_ids)
    end
  end

  describe '#authorization_request_types' do
    it 'returns classified authorization request types' do
      grant(:instructor, 'api_entreprise')

      expect(user.roles_for(:instructor).authorization_request_types).to eq(["AuthorizationRequest::#{'api_entreprise'.classify}"])
    end
  end

  describe '#authorization_definitions' do
    it 'returns authorization definitions for matching roles' do
      grant(:instructor, 'api_entreprise')

      result = user.roles_for(:instructor).authorization_definitions

      expect(result.map(&:id)).to include('api_entreprise')
    end
  end
end
