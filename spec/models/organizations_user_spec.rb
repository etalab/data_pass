require 'rails_helper'

RSpec.describe OrganizationsUser do
  describe '#set_as_current!' do
    let(:user) { create(:user, skip_organization_creation: true) }
    let(:first_organization) { create(:organization) }
    let(:second_organization) { create(:organization) }
    let(:third_organization) { create(:organization) }

    let!(:first_org_user) do
      create(:organizations_user, user:, organization: first_organization, current: true)
    end

    let!(:second_org_user) do
      create(:organizations_user, user:, organization: second_organization, current: false)
    end

    let!(:third_org_user) do
      create(:organizations_user, user:, organization: third_organization, current: false)
    end

    it 'sets the organization_user as current' do
      expect(second_org_user.current).to be false

      second_org_user.set_as_current!

      expect(second_org_user.reload.current).to be true
    end

    it 'unsets other organization_users as current for the same user' do
      expect(first_org_user.current).to be true

      second_org_user.set_as_current!

      expect(first_org_user.reload.current).to be false
      expect(third_org_user.reload.current).to be false
    end

    it 'ensures only one organization is current for a user' do
      second_org_user.set_as_current!

      current_count = user.organizations_users.where(current: true).count
      expect(current_count).to eq(1)
      expect(user.organizations_users.current.first).to eq(second_org_user)
    end

    it 'updates the user current_organization association' do
      expect(user.current_organization).to eq(first_organization)

      second_org_user.set_as_current!

      expect(user.reload.current_organization).to eq(second_organization)
    end

    it 'is transactional' do
      allow(second_org_user).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      expect { second_org_user.set_as_current! }.to raise_error(ActiveRecord::RecordInvalid)

      expect(first_org_user.reload.current).to be true
      expect(second_org_user.reload.current).to be false
    end
  end

  describe 'validations' do
    it 'validates uniqueness of organization_id scoped to user_id' do
      user = User.create!(email: 'unique@test.com')
      organization = create(:organization)
      create(:organizations_user, user:, organization:)

      duplicate = build(:organizations_user, user:, organization:)
      expect(duplicate).not_to be_valid
    end
  end
end
