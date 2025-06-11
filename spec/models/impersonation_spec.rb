require 'rails_helper'

RSpec.describe Impersonation do
  it 'has a valid factory' do
    expect(build(:impersonation)).to be_valid
  end

  describe 'associations' do
    it 'belongs to user' do
      impersonation = build(:impersonation)
      expect(impersonation).to respond_to(:user)
      expect(impersonation.user).to be_a(User)
    end

    it 'belongs to admin' do
      impersonation = build(:impersonation)
      expect(impersonation).to respond_to(:admin)
      expect(impersonation.admin).to be_a(User)
    end

    it 'has many impersonation_actions' do
      impersonation = create(:impersonation)
      action = create(:impersonation_action, impersonation: impersonation)
      expect(impersonation.impersonation_actions).to include(action)
    end
  end

  describe 'validations' do
    it 'requires a reason' do
      impersonation = build(:impersonation, reason: nil)
      expect(impersonation).not_to be_valid
      expect(impersonation.errors[:reason]).to be_present
    end
  end
end
