# frozen_string_literal: true

RSpec.describe Admin::UnbanUser do
  describe '.call' do
    subject(:unban_user) { described_class.call(params) }

    let(:params) do
      {
        target_user:,
        admin:,
      }
    end
    let(:admin) { create(:user, roles: ['admin']) }
    let(:target_user) { create(:user, banned_at: Time.zone.now, ban_reason: 'Compte compromis') }

    context 'when all conditions are met' do
      it { is_expected.to be_success }

      it 'unbans the user' do
        expect { unban_user }.to change { target_user.reload.banned? }.from(true).to(false)
      end

      it 'clears the ban reason' do
        unban_user
        expect(target_user.reload.ban_reason).to be_nil
      end

      it 'creates an admin event' do
        expect { unban_user }.to change(AdminEvent, :count).by(1)

        expect(AdminEvent.last.name).to eq('user_unbanned')
      end
    end

    context 'when user is not banned' do
      let(:target_user) { create(:user) }

      it { is_expected.to be_success }

      it 'does not change banned state' do
        expect { unban_user }.not_to(change { target_user.reload.banned? })
      end
    end
  end
end
