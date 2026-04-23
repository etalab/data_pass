require 'rails_helper'

RSpec.describe Admin::StopImpersonation do
  describe '.call' do
    subject(:stop_impersonation) { described_class.call(params) }

    let(:params) do
      {
        admin:,
        impersonation:
      }
    end
    let(:admin) { create(:user, roles: ['admin']) }
    let(:impersonation) { create(:impersonation, admin:) }

    context 'when all conditions are met' do
      it { is_expected.to be_success }

      it 'finishes the impersonation' do
        expect(impersonation.finished_at).to be_nil

        stop_impersonation

        expect(impersonation.reload.finished_at).to be_present
      end

      it 'creates an admin event' do
        expect {
          stop_impersonation
        }.to change(AdminEvent, :count).by(1)

        admin_event = AdminEvent.last

        expect(admin_event.name).to eq('stop_impersonation')
        expect(admin_event.admin).to eq(admin)
        expect(admin_event.entity).to eq(impersonation)
      end
    end

    context 'when impersonation is already finished' do
      let(:impersonation) { create(:impersonation, admin:, finished_at: 1.hour.ago) }

      it { is_expected.to be_success }

      it 'does not change finished_at' do
        original_finished_at = impersonation.finished_at

        stop_impersonation

        expect(impersonation.reload.finished_at).to eq(original_finished_at)
      end

      it 'still creates an admin event' do
        expect {
          stop_impersonation
        }.to change(AdminEvent, :count).by(1)
      end
    end

    context 'when impersonation is nil' do
      let(:impersonation) { nil }
      let(:other_unfinished_impersonation) { create(:impersonation, admin:) }

      it 'marks the other impersonation as finished' do
        expect {
          stop_impersonation
        }.to change { other_unfinished_impersonation.reload.finished_at }
      end
    end
  end
end
