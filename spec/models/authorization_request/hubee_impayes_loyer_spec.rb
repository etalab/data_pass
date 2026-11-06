RSpec.describe AuthorizationRequest::HubEEImpayesLoyer do
  REQUIRED_CONTACT_ATTRIBUTES = %w[family_name given_name email phone_number].freeze

  subject(:authorization_request) { build(:authorization_request, :hubee_impayes_loyer, :submitted) }

  let(:attributes) { {} }

  before { attributes.each { |attribute, value| authorization_request.public_send(:"#{attribute}=", value) } }

  it { is_expected.to be_valid }

  describe 'contacts' do
    it 'requires an administrateur local, a DPO and a RSSI' do
      expect(described_class.contact_types).to contain_exactly(:administrateur_metier, :delegue_protection_donnees, :rssi)
    end

    %i[administrateur_metier delegue_protection_donnees rssi].each do |contact|
      REQUIRED_CONTACT_ATTRIBUTES.each do |attribute|
        context "when #{contact} #{attribute} is blank" do
          let(:attributes) { { "#{contact}_#{attribute}": '' } }

          it { is_expected.not_to be_valid }

          it 'reports the missing field' do
            authorization_request.valid?

            expect(authorization_request.errors).to include(:"#{contact}_#{attribute}")
          end
        end
      end
    end

    context 'when the administrateur local has no job title' do
      let(:attributes) { { administrateur_metier_job_title: '' } }

      it { is_expected.not_to be_valid }
    end

    %i[delegue_protection_donnees rssi].each do |contact|
      context "when #{contact} has no job title" do
        let(:attributes) { { "#{contact}_job_title": nil } }

        it { is_expected.to be_valid }
      end
    end

    context 'when a contact phone number is not a French one' do
      let(:attributes) { { administrateur_metier_phone_number: '+1 555 123 4567' } }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'personal email requirement' do
    it 'is requested for the administrateur local and the RSSI only' do
      requirements = described_class.contacts.to_h { |contact| [contact.type, contact.required_personal_email?] }

      expect(requirements).to eq(administrateur_metier: true, delegue_protection_donnees: false, rssi: true)
    end
  end

  describe 'unicity validation' do
    subject(:authorization_request) { build(:authorization_request, :hubee_impayes_loyer, organization:) }

    let(:organization) { create(:organization) }

    context 'when the organization already has a request of this type' do
      before { create(:authorization_request, :hubee_impayes_loyer, organization:) }

      it { is_expected.not_to be_valid }
    end

    context 'when the other request belongs to another organization' do
      before { create(:authorization_request, :hubee_impayes_loyer) }

      it { is_expected.to be_valid }
    end
  end
end
