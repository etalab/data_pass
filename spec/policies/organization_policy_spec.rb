RSpec.describe OrganizationPolicy do
  let(:instance) { described_class.new(UserContext.new(user, authentication_session:), organization) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:authentication_session) { { 'identity_provider_uid' => identity_provider_uid } }

  describe '#new? and #create?' do
    context 'when signed in through an identity provider that forbids linking organizations (fia2)' do
      let(:identity_provider_uid) { 'fia2v2' }

      it 'forbids linking an organization' do
        expect(instance.new?).to be(false)
        expect(instance.create?).to be(false)
      end
    end

    context 'when signed in through an identity provider that allows linking organizations (fia1)' do
      let(:identity_provider_uid) { 'fia1v2' }

      it 'allows linking an organization' do
        expect(instance.new?).to be(true)
        expect(instance.create?).to be(true)
      end
    end

    context 'when signed in through the local sign-in bypass' do
      let(:identity_provider_uid) { 'bypass' }

      it 'allows linking an organization, as for any unknown identity provider' do
        expect(instance.new?).to be(true)
        expect(instance.create?).to be(true)
      end
    end
  end

  describe '#create?' do
    let(:identity_provider_uid) { 'fia1v2' }

    context 'when the user already belongs to the organization' do
      before { user.add_to_organization(organization) }

      it 'forbids linking it again' do
        expect(instance.create?).to be(false)
      end
    end
  end
end
