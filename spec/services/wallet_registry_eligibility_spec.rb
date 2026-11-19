RSpec.describe WalletRegistryEligibility do
  subject(:eligibility) { described_class.new(organization:, applicant: user, dirigeant_verification:) }

  let(:user) { create(:user, skip_organization_creation: true) }
  let(:dirigeant_verification) { nil }

  before { user.add_to_organization(organization, current: true, verified: true) }

  context 'when the organization belongs to the public sector' do
    let(:organization) { create(:organization, siret: '21920023500014') }

    it 'lets the applicant start as a public agent' do
      expect(eligibility.capacity).to eq(:public_agent)
      expect(eligibility.violation).to be_nil
    end
  end

  context 'when the organization is a private company' do
    let(:organization) { create(:organization, siret: '32816124500027') }

    it 'asks for the dirigeant certification' do
      expect(eligibility.capacity).to be_nil
      expect(eligibility.violation).to eq(:executive_certification_required)
    end

    context 'when ProConnect certified the applicant as its dirigeant' do
      let(:dirigeant_verification) { DirigeantVerificationFact.build(user:, organization:) }

      it 'lets the applicant start as an executive' do
        expect(eligibility.capacity).to eq(:executive)
        expect(eligibility.violation).to be_nil
      end
    end

    context 'when the certification was given for another organization' do
      let(:dirigeant_verification) { DirigeantVerificationFact.build(user:, organization: create(:organization)) }

      it 'still asks for the certification' do
        expect(eligibility.violation).to eq(:executive_certification_required)
      end
    end

    context 'when the certification is more than an hour old' do
      let(:dirigeant_verification) { DirigeantVerificationFact.build(user:, organization:, verified_at: 2.hours.ago) }

      it 'still asks for the certification' do
        expect(eligibility.violation).to eq(:executive_certification_required)
      end
    end
  end

  context 'when the sector of the organization is not known yet' do
    let(:organization) { create(:organization, siret: '32816124500027') }

    before { organization.update!(insee_payload: nil) }

    it 'lets the applicant start, the sector being checked at submission' do
      expect(eligibility.capacity).to eq(:sector_pending)
      expect(eligibility.violation).to be_nil
    end

    context 'when ProConnect certified the applicant as its dirigeant' do
      let(:dirigeant_verification) { DirigeantVerificationFact.build(user:, organization:) }

      it 'lets the applicant start as an executive' do
        expect(eligibility.capacity).to eq(:executive)
      end
    end
  end
end
