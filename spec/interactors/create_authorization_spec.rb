RSpec.describe CreateAuthorization, type: :interactor do
  describe '#call' do
    subject(:create_authorization) { described_class.call(authorization_request:) }

    let!(:authorization_request) { create(:authorization_request, form_uid, fill_all_attributes: true) }

    context 'when authorization is created' do
      let(:form_uid) { :api_particulier }

      it 'creates an authorization for api_particulier' do
        expect { subject }.to change(Authorization, :count).by(1)
      end
    end

    context 'when documents are attached' do
      let(:form_uid) { :api_particulier }
      let(:file) { fixture_file_upload('spec/fixtures/another_dummy.pdf', 'application/pdf') }

      before do
        authorization_request.cadre_juridique_document.attach(io: File.open('spec/fixtures/another_dummy.pdf'), filename: 'another_document.pdf')
      end

      it 'attaches the file to the document' do
        create_authorization
        expect(create_authorization.authorization.documents.first.files.count).to eq(1)
      end
    end

    context 'with multiple files' do
      let(:form_uid) { :api_particulier }
      let(:files) do
        [
          fixture_file_upload('spec/fixtures/dummy.pdf', 'application/pdf'),
          fixture_file_upload('spec/fixtures/another_dummy.pdf', 'application/pdf')
        ]
      end

      before do
        authorization_request.update(cadre_juridique_document: files)
      end

      it 'attaches all files to the document' do
        subject
        expect(create_authorization.authorization.documents.first.files.count).to eq(2)
      end
    end
  end
end
