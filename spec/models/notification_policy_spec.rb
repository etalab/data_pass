RSpec.describe NotificationPolicy do
  let(:data_provider) { create(:data_provider, api_contract_options: { 'optional_notifications' => optional_notifications }) }
  let(:optional_notifications) { %w[applicant_submit_receipt instructors_new_request] }

  def delivered_by(policy, type)
    delivered = false
    policy.deliver(type) { delivered = true }
    delivered
  end

  describe '.allow_all' do
    subject(:policy) { described_class.allow_all }

    it { expect(delivered_by(policy, 'applicant_submit_receipt')).to be(true) }
    it { is_expected.not_to be_suppressed_any }
    it { expect(policy.warnings).to be_empty }
  end

  describe '.for_api_call' do
    subject(:policy) { described_class.for_api_call(data_provider:, action:, notifications:) }

    let(:action) { 'submit' }
    let(:notifications) { false }

    context 'when notifications are not disabled by the caller' do
      let(:notifications) { nil }

      it { expect(delivered_by(policy, 'applicant_submit_receipt')).to be(true) }
      it { is_expected.not_to be_suppressed_any }
      it { expect(policy.warnings).to be_empty }
    end

    context 'when the caller explicitly keeps notifications' do
      let(:notifications) { true }

      it { expect(delivered_by(policy, 'applicant_submit_receipt')).to be(true) }
      it { is_expected.not_to be_suppressed_any }
    end

    context 'when the caller disables notifications and the contract makes them all optional' do
      it 'skips the optional emails' do
        expect(delivered_by(policy, 'applicant_submit_receipt')).to be(false)
        expect(delivered_by(policy, 'instructors_new_request')).to be(false)
      end

      it 'remembers what it skipped and does not warn' do
        delivered_by(policy, 'applicant_submit_receipt')

        expect(policy.suppressed_types).to eq(%w[applicant_submit_receipt])
        expect(policy.warnings).to be_empty
      end

      it 'is not flagged as suppressed when no email was asked to go out' do
        expect(policy).not_to be_suppressed_any
      end
    end

    context 'when the contract makes only some notifications optional' do
      let(:optional_notifications) { %w[applicant_submit_receipt] }

      it 'sends the mandatory email and warns about it' do
        expect(delivered_by(policy, 'applicant_submit_receipt')).to be(false)
        expect(delivered_by(policy, 'instructors_new_request')).to be(true)

        expect(policy.warnings.pluck(:title)).to eq(['Notifications obligatoires'])
        expect(policy.warnings.first[:detail]).to include('instructors_new_request')
      end

      it 'does not warn about an email which was never sent' do
        delivered_by(policy, 'applicant_submit_receipt')

        expect(policy.warnings).to be_empty
      end
    end

    context 'when the contract makes every notification mandatory' do
      let(:optional_notifications) { [] }

      it 'sends the email and warns once' do
        2.times { delivered_by(policy, 'applicant_submit_receipt') }

        expect(policy).not_to be_suppressed_any
        expect(policy.warnings.size).to eq(1)
        expect(policy.kept_types).to eq(%w[applicant_submit_receipt])
      end
    end

    context 'when the contract declares a notification of another action as optional' do
      let(:optional_notifications) { %w[applicant_approval] }

      it { expect(delivered_by(policy, 'applicant_approval')).to be(true) }
    end

    context 'with the approve action' do
      let(:action) { 'approve' }
      let(:optional_notifications) { %w[applicant_approval gdpr_contacts_approval] }

      it 'skips only the optional approval emails' do
        expect(delivered_by(policy, 'gdpr_contacts_approval')).to be(false)
        expect(delivered_by(policy, 'france_connect_team')).to be(true)
      end
    end

    context 'with an action that sends no email' do
      let(:action) { 'create_by_api' }

      it { expect(delivered_by(policy, 'applicant_submit_receipt')).to be(true) }
    end

    context 'without data provider' do
      let(:data_provider) { nil }

      it { expect(delivered_by(policy, 'applicant_submit_receipt')).to be(true) }
    end
  end

  describe '.valid_value?' do
    [nil, true, false, 'true', 'false'].each do |value|
      it("accepts #{value.inspect}") { expect(described_class.valid_value?(value)).to be(true) }
    end

    ['flase', 'no', 0, 1, [], {}].each do |value|
      it("rejects #{value.inspect}") { expect(described_class.valid_value?(value)).to be(false) }
    end
  end
end
