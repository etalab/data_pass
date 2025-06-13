require 'rails_helper'

RSpec.describe Impersonation do
  it 'has a valid factory' do
    expect(build(:impersonation)).to be_valid
  end

  describe 'validations' do
    it 'validates that user and admin must be different' do
      user = create(:user)
      impersonation = build(:impersonation, user: user, admin: user)
      expect(impersonation).not_to be_valid
      expect(impersonation.errors[:user]).to include('ne peut pas être identique à l\'administrateur')
    end

    it 'validates user that is not an admin' do
      user = create(:user, :admin)
      impersonation = build(:impersonation, user: user, admin: create(:user, :admin))
      expect(impersonation).not_to be_valid
    end
  end

  describe '#active?' do
    subject { impersonation }

    context 'when it has been created recently' do
      context 'when finished_at is nil' do
        let(:impersonation) { build(:impersonation, finished_at: nil, created_at: 1.minute.ago) }

        it { is_expected.to be_active }
      end

      context 'when finished_at is present' do
        let(:impersonation) { build(:impersonation, finished_at: 1.hour.ago, created_at: 1.minute.ago) }

        it { is_expected.not_to be_active }
      end
    end

    context 'when it has been created a long time ago' do
      context 'when finished_at is nil' do
        let(:impersonation) { build(:impersonation, finished_at: nil, created_at: 1.year.ago) }

        it { is_expected.not_to be_active }
      end
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
