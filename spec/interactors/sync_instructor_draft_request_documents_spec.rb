require 'rails_helper'

RSpec.describe SyncInstructorDraftRequestDocuments, type: :interactor do
  subject(:result) { described_class.call(instructor_draft_request:, authorization_request:, authorization_request_params:) }

  let(:instructor_draft_request) { create(:instructor_draft_request) }
  let(:authorization_request) { instructor_draft_request.request }
  let(:upload) { fixture_file_upload('spec/fixtures/dummy.pdf', 'application/pdf') }
  let(:existing_signed_id) { instructor_draft_request.documents.first.files.first.signed_id }

  context 'when a file is uploaded on a draft without document' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(cadre_juridique_document: ['', upload])
    end

    it 'stores one document whose file content is really written' do
      expect { result }.to change(InstructorDraftRequestDocument, :count).by(1)

      file = instructor_draft_request.documents.first.files.first

      expect(file.download).to eq(Rails.root.join('spec/fixtures/dummy.pdf').binread)
    end
  end

  context 'when a file is added next to an existing one' do
    let(:instructor_draft_request) { create(:instructor_draft_request, :with_documents) }
    let(:another_upload) { fixture_file_upload('spec/fixtures/another_dummy.pdf', 'application/pdf') }
    let(:authorization_request_params) do
      ActionController::Parameters.new(cadre_juridique_document: ['', existing_signed_id, another_upload])
    end

    it 'keeps a single document with both files' do
      existing_signed_id

      expect { result }.not_to change(InstructorDraftRequestDocument, :count)

      expect(instructor_draft_request.documents.first.files.map { |file| file.filename.to_s }).to contain_exactly('dummy.pdf', 'another_dummy.pdf')
    end
  end

  context 'when only the sentinel is submitted' do
    let(:instructor_draft_request) { create(:instructor_draft_request, :with_documents) }
    let(:authorization_request_params) do
      ActionController::Parameters.new(cadre_juridique_document: [''])
    end

    it 'removes the files of the document' do
      result

      expect(instructor_draft_request.documents.first.files).not_to be_attached
    end
  end

  context 'when the key is absent from the params' do
    let(:instructor_draft_request) { create(:instructor_draft_request, :with_documents) }
    let(:authorization_request_params) do
      ActionController::Parameters.new(intitule: 'Title')
    end

    it 'leaves the document untouched' do
      result

      expect(instructor_draft_request.documents.first.files.map { |file| file.filename.to_s }).to eq(['dummy.pdf'])
    end
  end

  context 'when only the sentinel is submitted on a draft without document' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(cadre_juridique_document: [''])
    end

    it 'creates no document' do
      expect { result }.not_to change(InstructorDraftRequestDocument, :count)
    end
  end
end
