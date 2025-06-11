require 'rails_helper'

RSpec.describe ImpersonationAction do
  it 'has a valid factory' do
    expect(build(:impersonation_action)).to be_valid
  end

  describe 'associations' do
    it 'belongs to impersonation' do
      action = build(:impersonation_action)
      expect(action).to respond_to(:impersonation)
      expect(action.impersonation).to be_a(Impersonation)
    end
  end

  describe 'validations' do
    it 'requires an action' do
      action = build(:impersonation_action, action: nil)
      expect(action).not_to be_valid
      expect(action.errors[:action]).to be_present
    end

    it 'validates action is one of create, update, or destroy' do
      %w[create update destroy].each do |valid_action|
        action = build(:impersonation_action, action: valid_action)
        expect(action).to be_valid
      end

      action = build(:impersonation_action, action: 'invalid')
      expect(action).not_to be_valid
      expect(action.errors[:action]).to be_present
    end

    it 'requires a model_type' do
      action = build(:impersonation_action, model_type: nil)
      expect(action).not_to be_valid
      expect(action.errors[:model_type]).to be_present
    end

    it 'requires a model_id' do
      action = build(:impersonation_action, model_id: nil)
      expect(action).not_to be_valid
      expect(action.errors[:model_id]).to be_present
    end
  end
end
