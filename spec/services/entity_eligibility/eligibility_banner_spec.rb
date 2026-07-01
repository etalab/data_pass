RSpec.describe EntityEligibility::EligibilityBanner do
  subject(:banner) { described_class.new(authorization_request, verdict) }

  let(:authorization_request) do
    instance_double(AuthorizationRequest, validated?: validated, refused?: refused)
  end
  let(:verdict) { EntityEligibility::Verdict.new(status:) }

  let(:validated) { false }
  let(:refused) { false }

  context 'when the request is validated with an eligible verdict' do
    let(:status) { :eligible }
    let(:validated) { true }

    it 'reports a validated banner' do
      expect(banner).to be_visible
      expect(banner.status).to eq(:validated)
    end
  end

  context 'when the request is refused with an ineligible verdict' do
    let(:status) { :ineligible }
    let(:refused) { true }

    it 'reports a refused banner' do
      expect(banner).to be_visible
      expect(banner.status).to eq(:refused)
    end
  end

  context 'when the verdict is likely eligible' do
    let(:status) { :likely_eligible }

    it 'reports a likely_eligible banner for human review' do
      expect(banner).to be_visible
      expect(banner.status).to eq(:likely_eligible)
    end
  end

  context 'when the verdict is likely ineligible' do
    let(:status) { :likely_ineligible }

    it 'reports a likely_ineligible banner for human review' do
      expect(banner).to be_visible
      expect(banner.status).to eq(:likely_ineligible)
    end
  end

  context 'when the verdict is unknown' do
    let(:status) { :unknown }

    it 'reports no banner' do
      expect(banner).not_to be_visible
      expect(banner.status).to be_nil
    end
  end
end
