require 'rails_helper'

RSpec.describe Admin::StartImpersonation do
  describe '.call' do
    subject(:start_impersonation) { described_class.call(params) }

    let(:params) do
      {
        user_email:,
        admin:,
        impersonation_params: {
          reason:
        }
      }
    end
    let(:admin) { create(:user, roles: ['admin']) }
    let(:user_email) { create(:user).email }
    let(:reason) { 'Testing purposes' }

    context 'when all conditions are met' do
      it { is_expected.to be_success }

      it 'creates an impersonation' do
        expect(start_impersonation.impersonation).to be_persisted
      end

      it 'creates an admin event' do
        expect {
          start_impersonation
        }.to change(AdminEvent, :count).by(1)

        admin_event = AdminEvent.last

        expect(admin_event.name).to eq('start_impersonation')
      end
    end

    context 'when user is not found' do
      let(:user_email) { 'invalid@gouv.fr' }

      it { is_expected.to be_failure }

      it 'returns user_not_found error' do
        expect(start_impersonation.error).to eq(:user_not_found)
      end
    end

    context 'when model params are not valid' do
      let(:reason) { nil }

      it { is_expected.to be_failure }

      it 'fails with model_error error' do
        expect(start_impersonation.error).to eq(:model_error)
      end
    end
  end
end
