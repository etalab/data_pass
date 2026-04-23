# frozen_string_literal: true

RSpec.describe Admin::BanUser do
  describe '.call' do
    subject(:ban_user) { described_class.call(params) }

    let(:params) do
      {
        user_email:,
        ban_reason:,
        admin:,
      }
    end
    let(:admin) { create(:user, :admin) }
    let(:target_user) { create(:user) }
    let(:user_email) { target_user.email }
    let(:ban_reason) { 'Compte compromis (CSIRT)' }

    context 'when all conditions are met' do
      it { is_expected.to be_success }

      it 'bans the user' do
        expect { ban_user }.to change { target_user.reload.banned? }.from(false).to(true)
      end

      it 'stores the ban reason' do
        ban_user
        expect(target_user.reload.ban_reason).to eq(ban_reason)
      end

      it 'creates an admin event' do
        expect { ban_user }.to change(AdminEvent, :count).by(1)

        expect(AdminEvent.last.name).to eq('user_banned')
      end
    end

    context 'when user is not found' do
      let(:user_email) { 'inconnu@example.com' }

      it { is_expected.to be_failure }

      it 'returns user_not_found error' do
        expect(ban_user.error).to eq(:user_not_found)
      end
    end

    context 'when admin tries to ban themselves' do
      let(:user_email) { admin.email }

      it { is_expected.to be_failure }

      it 'returns cannot_ban_self error' do
        expect(ban_user.error).to eq(:cannot_ban_self)
      end

      it 'does not ban the admin' do
        expect { ban_user }.not_to(change { admin.reload.banned? })
      end
    end

    context 'when user is already banned' do
      let(:target_user) { create(:user, banned_at: Time.zone.now, ban_reason: 'Raison initiale') }

      it { is_expected.to be_failure }

      it 'returns already_banned error' do
        expect(ban_user.error).to eq(:already_banned)
      end

      it 'does not overwrite the original ban reason' do
        expect { ban_user }.not_to(change { target_user.reload.ban_reason })
      end
    end

    context 'when ban reason is blank' do
      let(:ban_reason) { '' }

      it { is_expected.to be_failure }

      it 'returns missing_reason error' do
        expect(ban_user.error).to eq(:missing_reason)
      end

      it 'does not ban the user' do
        expect { ban_user }.not_to(change { target_user.reload.banned? })
      end
    end
  end
end
