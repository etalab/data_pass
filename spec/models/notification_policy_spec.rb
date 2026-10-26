RSpec.describe NotificationPolicy do
  let(:data_provider) { create(:data_provider, api_contract_options: { 'optional_notifications' => optional_notifications }) }
  let(:optional_notifications) { %w[applicant_submit_receipt instructors_new_request] }

  describe '.allow_all' do
    subject(:policy) { described_class.allow_all }

    it { is_expected.not_to be_suppressed_any }
    it { is_expected.not_to be_suppress('applicant_submit_receipt') }
    it { expect(policy.warnings).to be_empty }
  end

  describe '.for_api_call' do
    subject(:policy) { described_class.for_api_call(data_provider:, action:, notifications:) }

    let(:action) { 'submit' }
    let(:notifications) { false }

    context 'when notifications are not disabled by the caller' do
      let(:notifications) { nil }

      it { is_expected.not_to be_suppressed_any }
      it { expect(policy.warnings).to be_empty }
    end

    context 'when the caller explicitly keeps notifications' do
      let(:notifications) { true }

      it { is_expected.not_to be_suppressed_any }
    end

    context 'when the caller disables notifications and the contract makes them all optional' do
      it { is_expected.to be_suppressed_any }
      it { is_expected.to be_suppress('applicant_submit_receipt') }
      it { is_expected.to be_suppress('instructors_new_request') }
      it { expect(policy.warnings).to be_empty }
    end

    context 'when the contract makes only some notifications optional' do
      let(:optional_notifications) { %w[applicant_submit_receipt] }

      it { is_expected.to be_suppress('applicant_submit_receipt') }
      it { is_expected.not_to be_suppress('instructors_new_request') }

      it 'warns about the mandatory notifications that are kept' do
        expect(policy.warnings.pluck(:title)).to eq(['Notifications obligatoires'])
        expect(policy.warnings.first[:detail]).to include('instructors_new_request')
      end
    end

    context 'when the contract makes every notification mandatory' do
      let(:optional_notifications) { [] }

      it { is_expected.not_to be_suppressed_any }
      it { expect(policy.warnings.size).to eq(1) }
    end

    context 'when the contract declares a notification of another action as optional' do
      let(:optional_notifications) { %w[applicant_approval] }

      it { is_expected.not_to be_suppressed_any }
    end

    context 'with the approve action' do
      let(:action) { 'approve' }
      let(:optional_notifications) { %w[applicant_approval gdpr_contacts_approval] }

      it { is_expected.to be_suppress('gdpr_contacts_approval') }
      it { is_expected.not_to be_suppress('france_connect_team') }
    end

    context 'with an action that sends no email' do
      let(:action) { 'create_by_api' }

      it { is_expected.not_to be_suppressed_any }
      it { expect(policy.warnings).to be_empty }
    end

    context 'without data provider' do
      let(:data_provider) { nil }

      it { is_expected.not_to be_suppressed_any }
      it { expect(policy.warnings.size).to eq(1) }
    end
  end
end
