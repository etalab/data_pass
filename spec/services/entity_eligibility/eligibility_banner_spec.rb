require 'rails_helper'

RSpec.describe EntityEligibility::EligibilityBanner do
  subject(:banner) { described_class.new(authorization_request, verdict) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise) }
  let(:verdict) { EntityEligibility::Verdict.new(status:) }
  let(:status) { :unknown }

  context 'when the request was auto-approved' do
    before { create(:authorization_request_event, :auto_approve, authorization_request:) }

    let(:status) { :eligible }

    it 'reports a validated banner' do
      expect(banner).to be_visible
      expect(banner.status).to eq(:validated)
    end
  end

  context 'when the request was auto-rejected' do
    before { create(:authorization_request_event, :auto_reject, authorization_request:) }

    let(:status) { :ineligible }

    it 'reports a refused banner' do
      expect(banner).to be_visible
      expect(banner.status).to eq(:refused)
    end
  end

  context 'when the request was approved by a human despite an eligible verdict' do
    before { create(:authorization_request_event, :approve, authorization_request:) }

    let(:status) { :eligible }

    it 'reports no banner' do
      expect(banner).not_to be_visible
      expect(banner.status).to be_nil
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

  context 'when the verdict is unknown and no auto-instruction happened' do
    let(:status) { :unknown }

    it 'reports no banner' do
      expect(banner).not_to be_visible
      expect(banner.status).to be_nil
    end
  end
end
