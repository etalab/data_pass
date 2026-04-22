RSpec.describe LinkApplicantToOrganization do
  describe '#call' do
    subject(:result) { described_class.call(applicant: user, organization:, identity_federator: 'unknown') }

    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    context 'when no link exists' do
      it { is_expected.to be_a_success }

      it 'creates an unverified link' do
        result

        org_user = user.organizations_users.find_by(organization:)

        expect(org_user).to be_present
        expect(org_user.verified).to be(false)
        expect(org_user.identity_federator).to eq('unknown')
      end

      it 'does not mark the new link as current' do
        result

        org_user = user.organizations_users.find_by(organization:)

        expect(org_user.current).to be(false)
      end
    end

    context 'when the applicant already has a current organization' do
      let(:other_organization) { create(:organization) }

      before { user.add_to_organization(other_organization, identity_federator: 'pro_connect', identity_provider_uid: 'pc-uid', verified: true, current: true) }

      it 'preserves the previous current_organization' do
        result

        expect(user.reload.current_organization).to eq(other_organization)
      end
    end

    context 'when an unverified link already exists' do
      before { user.add_to_organization(organization, identity_federator: 'unknown', verified: false) }

      it { is_expected.to be_a_success }

      it 'does not create a duplicate link' do
        expect { result }.not_to change(OrganizationsUser, :count)
      end

      it 'does not mutate the existing link' do
        result

        org_user = user.organizations_users.find_by(organization:)

        expect(org_user.identity_federator).to eq('unknown')
        expect(org_user.verified).to be(false)
      end
    end

    context 'when a verified link already exists' do
      before { user.add_to_organization(organization, identity_federator: 'pro_connect', identity_provider_uid: 'uid', verified: true) }

      it { is_expected.to be_a_success }

      it 'preserves the verified status and identity metadata' do
        result

        org_user = user.organizations_users.find_by(organization:)

        expect(org_user).to have_attributes(
          verified: true,
          identity_federator: 'pro_connect',
          identity_provider_uid: 'uid'
        )
      end
    end
  end
end
