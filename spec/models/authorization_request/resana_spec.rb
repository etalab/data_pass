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
