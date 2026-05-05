RSpec.describe AuthorizationCore::Documents do
  let(:pdf_file) { Rack::Test::UploadedFile.new('spec/fixtures/dummy.pdf', 'application/pdf') }

  describe 'MAX_FILES_PER_DOCUMENT' do
    it 'is set to 6' do
      expect(AuthorizationCore::Documents::MAX_FILES_PER_DOCUMENT).to eq(6)
    end
  end

  describe 'file limit validation' do
    let(:authorization_request) { build(:authorization_request, :api_declaration_cesu) }

    context 'when the number of files does not exceed the limit' do
      before do
        authorization_request.maquette_projet.attach(Array.new(6) { pdf_file })
      end

      it 'is valid' do
        expect(authorization_request).to be_valid
      end
    end

    context 'when the number of files exceeds the limit' do
      before do
        authorization_request.maquette_projet.attach(Array.new(7) { pdf_file })
      end

      it 'is invalid' do
        expect(authorization_request).not_to be_valid
      end

      it 'adds an explicit error message on the document field' do
        authorization_request.valid?
        expect(authorization_request.errors[:maquette_projet]).to include(
          'trop de fichiers joints (le maximum autorisé est 6 fichiers, obtenu 7)'
        )
      end
    end
  end
end
