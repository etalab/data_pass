RSpec.describe AuthorizationRequestFormPolicy do
  let(:instance) { described_class.new(user_context, authorization_request_form) }
  let(:user_context) { UserContext.new(user) }
  let(:user) { create(:user) }

  describe '#new?' do
    subject { instance.new? }

    describe 'HubEE' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('hubee-cert-dc') }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_cert_dc, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_cert_dc, applicant: user) }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'API Entreprise editeur form, hidden in favour of the qualification questionnaire' do
    let(:authorization_request_form) { AuthorizationRequestForm.find('api-entreprise-editeur') }

    it { expect(instance.new?).to be(false) }
    it { expect(instance.create?).to be(false) }
  end

  describe 'Registre wallet form, open to public agents and certified dirigeants' do
    let(:authorization_request_form) { AuthorizationRequestForm.find('registre-wallet') }
    let(:user) { create(:user, skip_organization_creation: true) }
    let(:organization) { create(:organization, siret: '32816124500027') }

    before { user.add_to_organization(organization, current: true, verified: true) }

    it 'refuses a private company without the dirigeant certification' do
      expect(instance.create?).to be(false)
      expect(instance.access_violation).to eq(:executive_certification_required)
    end

    context 'when ProConnect certified the applicant as its dirigeant' do
      let(:user_context) { UserContext.new(user, dirigeant_verification: DirigeantVerificationFact.build(user:, organization:)) }

      it { expect(instance.create?).to be(true) }
    end

    context 'when the organization belongs to the public sector' do
      let(:organization) { create(:organization, siret: '21920023500014') }

      it { expect(instance.create?).to be(true) }
    end

    context 'when nobody is signed in' do
      let(:user_context) { UserContext.new(nil) }

      it 'shows the starting page' do
        expect(instance.new?).to be(true)
      end
    end
  end

  describe '#create?' do
    subject { instance.create? }

    describe 'HubEE CertDC' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('hubee-cert-dc') }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_cert_dc, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_cert_dc, applicant: user) }

        it { is_expected.to be_falsey }
      end
    end

    describe 'HubEE DILA' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('hubee-dila') }

      context 'when there already is an authorization_request archived' do
        before { create(:authorization_request, :hubee_dila, :archived, applicant: user) }

        it { is_expected.to be_truthy }
      end

      context 'when there already is another authorization_request not archived' do
        before { create(:authorization_request, :hubee_dila, applicant: user) }

        it { is_expected.to be_falsey }
      end
    end
  end
end
