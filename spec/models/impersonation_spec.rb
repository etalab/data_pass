require 'rails_helper'

RSpec.describe Impersonation do
  describe 'validations' do
    it 'requires a reason' do
      impersonation = build(:impersonation, reason: nil)
      expect(impersonation).not_to be_valid
      expect(impersonation.errors[:reason]).to be_present
    end

    it 'validates that user and admin must be different' do
      user = create(:user)
      impersonation = build(:impersonation, user: user, admin: user)
      expect(impersonation).not_to be_valid
      expect(impersonation.errors[:user]).to include('ne peut pas être identique à l\'administrateur')
    end
  end

  describe 'scopes' do
    let(:active_impersonation) { create(:impersonation) }
    let(:finished_impersonation) { create(:impersonation, finished_at: 1.hour.ago) }

    it 'returns active impersonations' do
      expect(described_class.active).to include(active_impersonation)
      expect(described_class.active).not_to include(finished_impersonation)
    end

    it 'returns finished impersonations' do
      expect(described_class.finished).to include(finished_impersonation)
      expect(described_class.finished).not_to include(active_impersonation)
    end
  end

  describe '#active?' do
    it 'returns true when finished_at is nil' do
      impersonation = build(:impersonation, finished_at: nil)
      expect(impersonation).to be_active
    end

    it 'returns false when finished_at is present' do
      impersonation = build(:impersonation, finished_at: 1.hour.ago)
      expect(impersonation).not_to be_active
    end
  end

  describe '#finish!' do
    it 'sets finished_at to current time' do
      impersonation = create(:impersonation)
      expect(impersonation.finished_at).to be_nil

      freeze_time do
        impersonation.finish!
        expect(impersonation.finished_at).to be_within(1.second).of(Time.current)
      end
    end
  end
end
