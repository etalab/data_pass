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

    context 'with several authorization request types' do
      subject(:service) do
        described_class.new(%w[AuthorizationRequest::APIEntreprise AuthorizationRequest::APIParticulier], 'old_scope' => 'new_scope')
      end

      it 'renames the scope in requests of every given type' do
        api_entreprise_request = create_request(%w[old_scope])
        api_particulier_request = create(:authorization_request, :api_particulier, data: { 'scopes' => %w[old_scope].to_json })

        service.up

        expect([api_entreprise_request, api_particulier_request].map { |request| JSON.parse(request.reload.data['scopes']) })
          .to all(eq(%w[new_scope]))
      end
    end

    context 'when the renamed scope was already submitted by the applicant' do
      subject(:service) { described_class.new(request_type, 'old_scope' => 'new_scope') }

      it 'does not make a reopened authorization look modified when the applicant changed nothing' do
        authorization = create(:authorization, authorization_request_trait: :api_entreprise)
        request = authorization.request
        request.update_column(:data, request.data.merge('scopes' => %w[old_scope other_scope].to_s))
        authorization.update_column(:data, request.data)

        service.up
        request.reload.scopes = request.scopes
        request.save!(validate: false)

        expect(ReopeningChangesChecker.new(request.reload)).not_to be_changed
      end

      it 'does not attribute the rename to the applicant on their next submission' do
        request = create(:authorization_request, :api_entreprise, :submitted, scopes: %w[old_scope other_scope])

        service.up
        changelog = CreateAuthorizationRequestChangelog.call(authorization_request: request.reload).changelog

        expect(changelog.diff).not_to have_key('scopes')
      end

      it 'keeps an unsubmitted scope change of the applicant in their next submission history' do
        request = create(:authorization_request, :api_entreprise, :submitted, scopes: %w[old_scope other_scope])
        request.scopes = %w[old_scope other_scope added_by_applicant]
        request.save!(validate: false)

        service.up
        changelog = CreateAuthorizationRequestChangelog.call(authorization_request: request.reload).changelog

        expect(changelog.diff['scopes']).to eq([
          %w[new_scope other_scope],
          %w[added_by_applicant new_scope other_scope]
        ])
      end

      it 'does not attribute the rename to the applicant when their unsubmitted change had dropped the renamed scope' do
        request = create(:authorization_request, :api_entreprise, :submitted, scopes: %w[old_scope other_scope])
        request.scopes = %w[other_scope]
        request.save!(validate: false)

        service.up
        request.reload.scopes = %w[new_scope other_scope]
        request.save!(validate: false)
        changelog = CreateAuthorizationRequestChangelog.call(authorization_request: request.reload).changelog

        expect(changelog.diff).not_to have_key('scopes')
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
