require 'rails_helper'

RSpec.describe InstructorDraftRequest do
  it 'has valid factories' do
    expect(build(:instructor_draft_request)).to be_valid
  end

  describe 'instructor validation' do
    subject { build(:instructor_draft_request, authorization_request_class:, instructor:) }

    let(:authorization_request_class) { 'AuthorizationRequest::APIEntreprise' }
    let(:instructor) { create(:user, :instructor, authorization_request_types:) }

    context 'with instructor for authorization request class' do
      let(:authorization_request_types) { %w[api_entreprise] }

      it { is_expected.to be_valid }
    end

    context 'with another instructor' do
      let(:authorization_request_types) { %w[api_particulier] }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#attachments_for' do
    subject(:attachments) { draft.attachments_for(identifier) }

    let(:draft) { create(:instructor_draft_request, :with_documents) }

    context 'when the document has files' do
      let(:identifier) { :cadre_juridique_document }

      it 'returns the persisted attachments' do
        expect(attachments.map { |attachment| attachment.filename.to_s }).to eq(['dummy.pdf'])
      end
    end

    context 'when the document has no files' do
      let(:identifier) { :maquette_projet }

      it { is_expected.to be_empty }
    end

    context 'when the draft is not persisted' do
      subject(:attachments) { build(:instructor_draft_request).attachments_for(:cadre_juridique_document) }

      it { is_expected.to be_empty }
    end
  end
end
