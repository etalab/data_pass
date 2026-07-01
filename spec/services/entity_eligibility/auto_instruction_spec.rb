RSpec.describe EntityEligibility::AutoInstruction do
  subject(:auto_instruction) { described_class.new(authorization_request, verdict) }

  let(:authorization_request) do
    instance_double(AuthorizationRequest, validated?: validated, refused?: refused)
  end
  let(:verdict) { EntityEligibility::Verdict.new(status:) }

  let(:validated) { false }
  let(:refused) { false }

  context 'when the request is validated with an eligible verdict' do
    let(:status) { :eligible }
    let(:validated) { true }

    it 'reports a validated auto-instruction' do
      expect(auto_instruction).to be_happened
      expect(auto_instruction.status).to eq(:validated)
    end
  end

  context 'when the request is refused with an ineligible verdict' do
    let(:status) { :ineligible }
    let(:refused) { true }

    it 'reports a refused auto-instruction' do
      expect(auto_instruction).to be_happened
      expect(auto_instruction.status).to eq(:refused)
    end
  end

  context 'when the verdict is a grey area handled by a human' do
    let(:status) { :likely_eligible }

    it 'reports nothing' do
      expect(auto_instruction).not_to be_happened
      expect(auto_instruction.status).to be_nil
    end
  end
end
