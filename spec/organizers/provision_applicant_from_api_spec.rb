RSpec.describe ProvisionApplicantFromAPI, type: :organizer do
  describe '.call' do
    subject(:result) { described_class.call(applicant_params:, siret: '13002526500013') }

    let(:applicant_params) { { email: 'applicant@example.com', given_name: 'Jean', family_name: 'Dupont' } }

    it { is_expected.to be_a_success }

    it 'creates the applicant, the organization and an unverified link' do
      expect { result }.to change(User, :count).by(1)
        .and change(Organization, :count).by(1)
        .and change(OrganizationsUser, :count).by(1)

      link = result.applicant.organizations_users.find_by(organization: result.organization)

      expect(link.verified).to be(false)
      expect(link.identity_federator).to eq('unknown')
    end

    context 'when the organization cannot be created' do
      subject(:result) { described_class.call(applicant_params:, siret: 'not-a-siret') }

      it 'fails and leaves no applicant behind' do
        expect(result).to be_a_failure
        expect(User.find_by(email: 'applicant@example.com')).to be_nil
      end
    end
  end
end
