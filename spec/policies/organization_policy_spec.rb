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

  describe '#start_dirigeant_verification?' do
    let(:identity_provider_uid) { 'fia1v2' }

    {
      'a public organization' => ['21920023500014', false],
      'a private company' => ['32816124500027', true],
      'an organization whose sector is still unknown' => ['41040946000756', true]
    }.each do |description, (siret, allowed)|
      context "with #{description}" do
        let(:organization) { build(:organization, siret:) }

        it { expect(instance.start_dirigeant_verification?).to be(allowed) }
      end
    end

    context 'without organization, so that the organizer explains the missing SIREN' do
      let(:organization) { nil }

      it { expect(instance.start_dirigeant_verification?).to be(true) }
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
