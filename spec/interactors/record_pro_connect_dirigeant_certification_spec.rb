RSpec.describe RecordProConnectDirigeantCertification do
  subject(:record) { described_class.call(user:, organization:, verification: { verified_at: }) }

  let(:user) { create(:user) }
  let(:organization) { user.current_organization }
  let(:verified_at) { Time.zone.now.change(usec: 0) }

  it 'dates the dirigeant certification on the link between the user and the organization' do
    record

    expect(user.organizations_users.find_by(organization:).dirigeant_verified_at).to eq(verified_at)
  end

  it 'leaves the other organizations of the user uncertified' do
    other_organization = create(:organization)
    user.add_to_organization(other_organization)

    record

    expect(user.organizations_users.find_by(organization: other_organization).dirigeant_verified_at).to be_nil
  end
end
