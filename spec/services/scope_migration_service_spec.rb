require 'rails_helper'

RSpec.describe ScopeMigrationService do
  let(:request_type) { 'AuthorizationRequest::APIEntreprise' }

  def create_request(scopes)
    create(:authorization_request, :api_entreprise, data: { 'scopes' => scopes.to_json })
  end

  def create_authorization(scopes)
    create(:authorization, authorization_request_trait: :api_entreprise).tap do |a|
      a.update_column(:data, a.data.merge('scopes' => scopes.to_json))
    end
  end

  describe '#up' do
    context 'with a 1-to-1 scope rename' do
      subject(:service) { described_class.new(request_type, 'old_scope' => 'new_scope') }

      it 'renames the scope in matching authorization requests' do
        request = create_request(%w[old_scope other_scope])
        service.up
        expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('new_scope', 'other_scope')
      end

      it 'renames the scope in matching authorizations' do
        authorization = create_authorization(%w[old_scope other_scope])
        service.up
        expect(JSON.parse(authorization.reload.data['scopes'])).to contain_exactly('new_scope', 'other_scope')
      end

      it 'does not touch requests without the old scope' do
        request = create_request(%w[other_scope])
        service.up
        expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('other_scope')
      end

      it 'does not touch requests of other types' do
        request = create(:authorization_request, :api_particulier, data: { 'scopes' => %w[old_scope].to_json })
        service.up
        expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('old_scope')
      end
    end

    context 'with a 1-to-many scope split' do
      subject(:service) { described_class.new(request_type, 'old_scope' => %w[new_scope_a new_scope_b]) }

      it 'replaces old scope with both new scopes' do
        request = create_request(%w[old_scope other_scope])
        service.up
        expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('new_scope_a', 'new_scope_b', 'other_scope')
      end
    end
  end

  describe 'with multiple mappings' do
    subject(:service) { described_class.new(request_type, 'old_a' => 'new_a', 'old_b' => %w[new_b1 new_b2]) }

    it 'applies all mappings in up' do
      request = create_request(%w[old_a old_b other_scope])
      service.up
      expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('new_a', 'new_b1', 'new_b2', 'other_scope')
    end

    it 'reverts all mappings in down' do
      request = create_request(%w[new_a new_b1 new_b2 other_scope])
      service.down
      expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('old_a', 'old_b', 'other_scope')
    end
  end

  describe '#down' do
    context 'with a 1-to-1 scope rename' do
      subject(:service) { described_class.new(request_type, 'old_scope' => 'new_scope') }

      it 'reverts new scope back to old scope in requests' do
        request = create_request(%w[new_scope other_scope])
        service.down
        expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('old_scope', 'other_scope')
      end

      it 'reverts new scope back to old scope in authorizations' do
        authorization = create_authorization(%w[new_scope other_scope])
        service.down
        expect(JSON.parse(authorization.reload.data['scopes'])).to contain_exactly('old_scope', 'other_scope')
      end
    end

    context 'with a 1-to-many scope split' do
      subject(:service) { described_class.new(request_type, 'old_scope' => %w[new_scope_a new_scope_b]) }

      it 'merges new scopes back to old scope' do
        request = create_request(%w[new_scope_a new_scope_b other_scope])
        service.down
        expect(JSON.parse(request.reload.data['scopes'])).to contain_exactly('old_scope', 'other_scope')
      end
    end
  end
end
