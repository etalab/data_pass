RSpec.describe IdentityProvider do
  let(:proconnect_identity_provider) { described_class.find('71144ab3-ee1a-4401-b7b3-79b44f7daeeb') }
  let(:dgfip_identity_provider) { described_class.find('fia1v2') }
  let(:renater_identity_provider) { described_class.find('fia2v2') }

  describe '.all' do
    subject { described_class.all }

    it 'works' do
      expect(described_class.all).to be_all { |a| a.is_a? IdentityProvider }
    end
  end

  describe '.find' do
    subject { described_class.find(uid) }

    context 'when uid does not exists in backend' do
      let(:uid) { 'unknown-uid' }

      it 'renders an unknown identity provider' do
        expect(subject).to be_a(described_class)
        expect(subject.id).to eq('unknown-uid')
        expect(subject.name).to eq('Unknown')
      end
    end
  end

  describe '#choose_organization_on_sign_in?' do
    subject { identity_provider.choose_organization_on_sign_in? }

    describe 'DGFIP provider' do
      let(:identity_provider) { dgfip_identity_provider }

      it { is_expected.to be(true) }
    end

    describe 'ProConnect identity provider' do
      let(:identity_provider) { proconnect_identity_provider }

      it { is_expected.to be(false) }
    end
  end

  describe '#can_link_to_organizations?' do
    subject { identity_provider.can_link_to_organizations? }

    describe 'DGFIP provider' do
      let(:identity_provider) { dgfip_identity_provider }

      it { is_expected.to be(true) }
    end

    describe 'Renater provider' do
      let(:identity_provider) { renater_identity_provider }

      it { is_expected.to be(false) }
    end

    describe 'ProConnect identity provider' do
      let(:identity_provider) { proconnect_identity_provider }

      it { is_expected.to be(false) }
    end
  end

  describe '#siret_verified?' do
    subject { identity_provider.siret_verified? }

    describe 'DGFIP provider' do
      let(:identity_provider) { dgfip_identity_provider }

      it { is_expected.to be(false) }
    end

    describe 'ProConnect identity provider' do
      let(:identity_provider) { proconnect_identity_provider }

      it { is_expected.to be(true) }
    end
  end

  describe '#linked_to_organizations_verified?' do
    subject { identity_provider.linked_to_organizations_verified? }

    describe 'DGFIP provider' do
      let(:identity_provider) { dgfip_identity_provider }

      it { is_expected.to be(false) }
    end

    describe 'ProConnect identity provider' do
      let(:identity_provider) { proconnect_identity_provider }

      it { is_expected.to be(true) }
    end
  end
end
