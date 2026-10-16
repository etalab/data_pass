RSpec.describe AuthorizationRequestCreationRules do
  subject(:violation) { described_class.for_form(form, organization:, applicant:).creation_violation }

  let(:form) { AuthorizationRequestForm.find('api-entreprise') }
  let(:organization) { create(:organization) }
  let(:applicant) { create(:user) }

  it { is_expected.to be_nil }

  context 'when the applicant is banned' do
    let(:applicant) { create(:user, banned_at: Time.zone.now, ban_reason: 'Abus') }

    it { is_expected.to eq(:applicant_banned) }
  end

  context 'when the form cannot be started by an applicant' do
    let(:form) { AuthorizationRequestForm.find('api-r2p-production') }

    it { is_expected.to eq(:form_not_startable) }
  end

  context 'when the organization is closed' do
    before { organization.update!(insee_payload: closed_insee_payload) }

    let(:closed_insee_payload) do
      { 'etablissement' => { 'periodesEtablissement' => [{ 'dateFin' => nil, 'etatAdministratifEtablissement' => 'F' }] } }
    end

    it { is_expected.to eq(:organization_closed) }
  end

  context 'when the definition is unique and a request is already active in the organization' do
    let(:form) { AuthorizationRequestForm.find('hubee-dila') }

    before { create(:authorization_request, :hubee_dila, organization:, applicant: create(:user, current_organization: organization)) }

    it { is_expected.to eq(:unicity_violated) }
  end

  context 'when the definition is unique and the existing request is archived' do
    let(:form) { AuthorizationRequestForm.find('hubee-dila') }

    before { create(:authorization_request, :hubee_dila, :archived, organization:, applicant: create(:user, current_organization: organization)) }

    it { is_expected.to be_nil }
  end

  describe '.for_definition' do
    subject(:violation) { described_class.for_definition(definition, organization:, applicant:).access_violation }

    let(:definition) { AuthorizationDefinition.find('api_r2p') }

    it 'does not require the form to be startable by an applicant' do
      expect(violation).to be_nil
    end

    context 'when the organization is closed' do
      before { organization.update!(insee_payload: { 'etablissement' => { 'periodesEtablissement' => [{ 'dateFin' => nil, 'etatAdministratifEtablissement' => 'F' }] } }) }

      it { is_expected.to eq(:organization_closed) }
    end

    context 'when the applicant is banned' do
      let(:applicant) { create(:user, banned_at: Time.zone.now, ban_reason: 'Abus') }

      it { is_expected.to eq(:applicant_banned) }
    end
  end

  describe '.for_request_class' do
    subject(:violation) { described_class.for_request_class(request_class, organization:, applicant:).creation_violation }

    let(:request_class) { AuthorizationRequest::HubEECertDC }

    it { is_expected.to be_nil }

    context 'when a request of this unique type is already active in the organization' do
      before { create(:authorization_request, :hubee_cert_dc, organization:, applicant: create(:user, current_organization: organization)) }

      it { is_expected.to eq(:unicity_violated) }
    end

    context 'when the request of this unique type is refused' do
      before { create(:authorization_request, :hubee_cert_dc, :refused, organization:, applicant: create(:user, current_organization: organization)) }

      it { is_expected.to be_nil }
    end
  end
end
