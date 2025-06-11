require 'rails_helper'

RSpec.describe Admin::StartImpersonation do
  describe '.call' do
    let(:admin) { create(:user, roles: ['admin']) }
    let(:target_user) { create(:user) }
    let(:session) { {} }
    let(:reason) { 'Testing purposes' }

    context 'when all conditions are met' do
      it 'creates an impersonation and starts session' do
        result = described_class.call(
          user_identifier: target_user.email,
          admin: admin,
          reason: reason,
          session: session
        )

        expect(result).to be_success
        expect(result.target_user).to eq(target_user)
        expect(result.impersonation).to be_persisted
        expect(session[:impersonated_user_id]).to eq(target_user.id)
      end
    end

    context 'when user is not found' do
      it 'fails with user_not_found error' do
        result = described_class.call(
          user_identifier: 'nonexistent@example.com',
          admin: admin,
          reason: reason,
          session: session
        )

        expect(result).to be_failure
        expect(result.error).to eq(:user_not_found)
      end
    end

    context 'when admin tries to impersonate themselves' do
      it 'fails with cannot_impersonate_self error' do
        result = described_class.call(
          user_identifier: admin.email,
          admin: admin,
          reason: reason,
          session: session
        )

        expect(result).to be_failure
        expect(result.error).to eq(:cannot_impersonate_self)
      end
    end

    context 'when non-admin tries to impersonate' do
      let(:non_admin) { create(:user) }

      it 'fails with unauthorized error' do
        result = described_class.call(
          user_identifier: target_user.email,
          admin: non_admin,
          reason: reason,
          session: session
        )

        expect(result).to be_failure
        expect(result.error).to eq(:unauthorized)
      end
    end

    context 'when trying to impersonate another admin' do
      let(:target_admin) { create(:user, roles: ['admin']) }

      it 'fails with cannot_impersonate_admin error' do
        result = described_class.call(
          user_identifier: target_admin.email,
          admin: admin,
          reason: reason,
          session: session
        )

        expect(result).to be_failure
        expect(result.error).to eq(:cannot_impersonate_admin)
      end
    end
  end
end
