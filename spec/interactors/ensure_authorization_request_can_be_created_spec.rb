RSpec.describe EnsureAuthorizationRequestCanBeCreated do
  subject(:result) do
    described_class.call(authorization_request_form: form, organization:, applicant:)
  end

  let(:form) { AuthorizationRequestForm.find('api-entreprise') }
  let(:organization) { create(:organization) }
  let(:applicant) { create(:user) }

  it { is_expected.to be_a_success }

  context 'when the applicant is banned' do
    let(:applicant) { create(:user, banned_at: Time.zone.now, ban_reason: 'Abus') }

    it 'fails with applicant_banned' do
      expect(result).to be_a_failure
      expect(result.error[:key]).to eq(:applicant_banned)
    end
  end

  context 'when the form cannot be started by an applicant' do
    let(:form) { AuthorizationRequestForm.find('api-r2p-production') }

    it 'fails with form_not_startable' do
      expect(result.error[:key]).to eq(:form_not_startable)
    end
  end
end
