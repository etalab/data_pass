RSpec.describe AuthorizationRequest::Resana do
  subject(:authorization_request) { build(:authorization_request, :resana, fill_all_attributes: true) }

  let(:letter) { Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf') }

  it 'is submittable once both steps and terms are filled' do
    expect(authorization_request).to be_valid(:submit)
  end

  describe 'legal framework' do
    it 'requires a legal nature' do
      authorization_request.nature_juridique = nil

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors[:nature_juridique]).to be_present
    end

    it 'rejects a legal nature outside the list' do
      authorization_request.nature_juridique = 'commune'

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors[:nature_juridique]).to be_present
    end

    it 'requires the Resana organisations' do
      authorization_request.organisations_resana = ''

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors[:organisations_resana]).to be_present
    end

    it 'offers no local authority' do
      expect(described_class::NATURES_JURIDIQUES.grep(/collectivit|commune|departement|region/)).to be_empty
    end

    it 'requires the certification or a letter' do
      authorization_request.habilitation_certifiee = '0'

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors[:habilitation_certifiee]).to be_present
      expect(authorization_request.errors[:lettre_habilitation_document]).to be_present
    end

    it 'accepts a certification given as a boolean' do
      authorization_request.habilitation_certifiee = true

      expect(authorization_request).to be_valid(:submit)
    end

    it 'accepts a letter without certification' do
      authorization_request.habilitation_certifiee = '0'
      authorization_request.lettre_habilitation_document.attach(letter)

      expect(authorization_request).to be_valid(:submit)
    end

    it 'keeps both the certification and the letter' do
      authorization_request.lettre_habilitation_document.attach(letter)

      expect(authorization_request).to be_valid(:submit)
      expect(authorization_request.habilitation_certifiee).to be(true)
    end

    it 'rejects a letter which is not a PDF' do
      authorization_request.lettre_habilitation_document.attach(Rack::Test::UploadedFile.new('spec/fixtures/dummy.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'))

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors[:lettre_habilitation_document]).to be_present
    end
  end

  describe 'contacts and terms' do
    it 'asks for the data protection officer then the business owner' do
      expect(authorization_request.contact_types).to eq(%i[delegue_protection_donnees contact_metier])
    end

    it 'does not ask for the data protection officer job title' do
      authorization_request.delegue_protection_donnees_job_title = nil

      expect(authorization_request).to be_valid(:submit)
    end

    it 'requires the data protection officer phone number' do
      authorization_request.delegue_protection_donnees_phone_number = nil

      expect(authorization_request).not_to be_valid(:submit)
    end

    it 'requires the business owner job title' do
      authorization_request.contact_metier_job_title = nil

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors.full_messages_for(:contact_metier_job_title)).to include(a_string_starting_with('Fonction du responsable métier'))
    end

    it 'lets only the business owner be filled with the applicant data' do
      fillable = described_class.contacts.index_by(&:type).transform_values(&:fill_data_with_applicant_data?)

      expect(fillable).to eq(delegue_protection_donnees: false, contact_metier: true)
    end

    it 'requires the data protection officer email' do
      authorization_request.delegue_protection_donnees_email = nil

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors[:delegue_protection_donnees_email]).to be_present
    end

    it 'requires Resana terms of service to be accepted' do
      authorization_request.terms_of_service_accepted = false

      expect(authorization_request).not_to be_valid(:submit)
      expect(authorization_request.errors[:base]).to be_present
    end

    it 'requires the data protection officer to be informed' do
      authorization_request.data_protection_officer_informed = false

      expect(authorization_request).not_to be_valid(:submit)
    end
  end
end
