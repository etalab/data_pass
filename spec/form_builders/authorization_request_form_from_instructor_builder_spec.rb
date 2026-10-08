require 'rails_helper'

RSpec.describe AuthorizationRequestFormFromInstructorBuilder, type: :helper do
  subject(:builder) do
    described_class.new(:authorization_request, draft.request, helper, { instructor_draft_request: draft })
  end

  let(:draft) { create(:instructor_draft_request, :with_documents) }

  describe '#dsfr_file_field' do
    subject(:html) { builder.dsfr_file_field(:cadre_juridique_document) }

    let(:signed_id) { draft.documents.first.files.first.signed_id }

    it 'shows the file stored on the draft' do
      expect(html).to include('dummy.pdf')
    end

    it 'shows the remove button' do
      expect(html).to include('file-with-remove-button')
    end

    it 'keeps the stored file through a hidden signed id field' do
      expect(html).to include(%(value="#{signed_id}"))
    end

    it 'adds the sentinel field' do
      expect(html).to include('authorization_request_cadre_juridique_document_sentinel')
    end

    context 'when the draft has no file for the attribute' do
      subject(:html) { builder.dsfr_file_field(:maquette_projet) }

      it 'renders neither link nor hidden fields' do
        expect(html).not_to include('file-with-remove-button')
        expect(html).not_to include('_sentinel')
      end
    end
  end
end
