RSpec.describe APIAccessPolicy do
  subject(:policy) { described_class.new(context, definition) }

  let(:definition) { AuthorizationDefinition.find('api_entreprise') }
  let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner:) }
  let(:context) { APIUserContext.new(owner, nil, oauth_application: application) }
  let(:data_provider) do
    DataProvider.find_by(slug: definition.provider_slug) || create(:data_provider, slug: definition.provider_slug)
  end

  describe '#submit?' do
    subject { policy.submit? }

    context 'without any grant' do
      it { is_expected.to be false }
    end

    context 'with an active submission grant for the provider of the type' do
      before { create(:api_access_grant, oauth_application: application, data_provider:) }

      it { is_expected.to be true }
    end

    context 'with a validation grant only' do
      before { create(:api_access_grant, :validation, oauth_application: application, data_provider:) }

      it { is_expected.to be false }
    end

    context 'with a revoked submission grant' do
      before { create(:api_access_grant, :revoked, oauth_application: application, data_provider:) }

      it { is_expected.to be false }
    end

    context 'when the grant becomes revoked after being created' do
      before do
        grant = create(:api_access_grant, oauth_application: application, data_provider:)
        grant.revoke!(by_email: 'admin@example.com', reason: 'Retrait')
      end

      it { is_expected.to be false }
    end

    context 'with a grant on another provider than the one of the type' do
      let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise api_droits_cnam]) }
      let(:other_data_provider) do
        slug = AuthorizationDefinition.find('api_droits_cnam').provider_slug
        DataProvider.find_by(slug:) || create(:data_provider, slug:)
      end

      before { create(:api_access_grant, oauth_application: application, data_provider: other_data_provider) }

      it { is_expected.to be false }

      it 'still allows the type of the provider that was granted' do
        other_definition = AuthorizationDefinition.find('api_droits_cnam')

        expect(described_class.new(context, other_definition).submit?).to be true
      end
    end

    context 'with a grant held by another application of the same owner' do
      before { create(:api_access_grant, oauth_application: create(:oauth_application, owner:), data_provider:) }

      it { is_expected.to be false }
    end

    context 'when the definition has no provider' do
      before { allow(definition).to receive(:provider).and_return(nil) }

      it { is_expected.to be false }
    end

    context 'when the owner has no developer role on the type anymore' do
      before do
        create(:api_access_grant, oauth_application: application, data_provider:)
        owner.update!(roles: [])
      end

      it { is_expected.to be false }
    end
  end

  describe 'when the application has no owner' do
    let(:context) { APIUserContext.new(nil, nil, oauth_application: application) }

    it 'refuses without raising' do
      expect(policy.submit?).to be false
      expect(policy.validate?).to be false
    end
  end

  describe 'when there is no oauth application' do
    let(:context) { APIUserContext.new(owner, nil, oauth_application: nil) }

    it 'refuses without raising' do
      expect(policy.submit?).to be false
      expect(policy.validate?).to be false
    end
  end

  describe '#validate?' do
    subject { policy.validate? }

    context 'with an active validation grant for the provider of the type' do
      before { create(:api_access_grant, :validation, oauth_application: application, data_provider:) }

      it { is_expected.to be true }
    end

    context 'with a submission grant only' do
      before { create(:api_access_grant, oauth_application: application, data_provider:) }

      it { is_expected.to be false }
    end
  end
end
