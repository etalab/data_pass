require 'rails_helper'

RSpec.describe DemandStatus, type: :model do
  subject(:demand_status) { described_class.new(authorization_request) }

  let(:authorization_request) { create(:authorization_request, :api_impot_particulier_sandbox, :validated) }

  describe '#completed_cycles' do
    subject(:completed_cycles) { demand_status.completed_cycles }

    context 'when there are no completed cycles' do
      it { is_expected.to eq(0) }
    end

    context 'when there are completed cycles' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :validated) }

      it { is_expected.to be_positive }
    end
  end

  describe '#incomplete_cycle?' do
    subject(:incomplete_cycle?) { demand_status.incomplete_cycle? }

    context 'when the cycle is incomplete' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production) }

      it { is_expected.to be_truthy }
    end

    context 'when the cycle is complete' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :validated) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#multi_stage?' do
    subject(:multi_stage?) { demand_status.multi_stage? }

    context 'when the project has multiple stages' do
      it { is_expected.to be_truthy }
    end

    context 'when the project has a single stage' do
      let(:authorization_request) { build(:authorization_request) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#stage' do
    subject(:stage) { demand_status.stage }

    context 'when the project has an authorization' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :validated) }
      let(:expected_stage) { AuthorizationDefinition::Stage.new(type: 'production', previouses: [{ id: 'api_impot_particulier_sandbox', form_id: 'api-impot-particulier-sandbox' }]) }

      it { is_expected.to eq(expected_stage) }
    end

    context 'when the project has no authorization' do
      let(:authorization_request) { build(:authorization_request, :api_impot_particulier_sandbox) }
      let(:expected_stage) { AuthorizationDefinition::Stage.new(type: 'sandbox', next: { id: 'api_impot_particulier', form_id: 'api-impot-particulier-production' }) }

      it { is_expected.to eq(expected_stage) }
    end
  end

  describe '#ready_for_next_stage?' do
    subject(:ready_for_next_stage?) { demand_status.ready_for_next_stage? }

    context 'when the project is validated and has a next stage' do
      it { is_expected.to be_truthy }
    end

    context 'when the project is not validated' do
      let(:authorization_request) { build(:authorization_request, :api_impot_particulier_production) }

      it { is_expected.to be_falsey }
    end

    context 'when the project has no next stage' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#next_stage_in_progress?' do
    subject(:next_stage_in_progress?) { demand_status.next_stage_in_progress? }

    context 'when the project is submitted and has a next stage' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, :submitted) }

      it { is_expected.to be_truthy }
    end

    context 'when the project is not submitted' do
      it { is_expected.to be_falsey }
    end

    context 'when the project has no next stage' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#next_stage' do
    subject(:next_stage) { demand_status.next_stage }

    context 'when the project has a next stage' do
      let(:expected_stage) { AuthorizationDefinition::Stage.new(type: 'production', previouses: [{ id: 'api_impot_particulier_sandbox', form_id: 'api-impot-particulier-sandbox' }]) }

      it { is_expected.to eq(expected_stage) }
    end

    context 'when the project has no next stage' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis) }

      it { is_expected.to be_nil }
    end
  end

  describe '#final_stage?' do
    subject(:final_stage?) { demand_status.final_stage? }

    context 'when the project has no next stage' do
      let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis) }

      it { is_expected.to be_truthy }
    end

    context 'when the project has a next stage' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#ongoing_reopening?' do
    subject(:ongoing_reopening?) { demand_status.ongoing_reopening? }

    context 'when the project is reopening' do
      let(:authorization_request) { create(:authorization_request, :api_impot_particulier_production, reopening: true) }

      it { is_expected.to be_truthy }
    end

    context 'when the project is not reopening' do
      it { is_expected.to be_falsey }
    end
  end
end
