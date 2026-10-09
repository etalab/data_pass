require 'rails_helper'

RSpec.describe UpdateInstructorDraftRequest, type: :organizer do
  subject(:organizer) { described_class.call(params) }

  let(:params) do
    {
      instructor_draft_request:,
      authorization_request_params:,
    }
  end
  let!(:instructor) { create(:user, :instructor) }
  let!(:instructor_draft_request) do
    create(
      :instructor_draft_request,
      instructor:,
      authorization_request_class: 'AuthorizationRequest::APIEntreprise',
      data: {
        'intitule' => 'Original title',
        'description' => 'Original description',
      }
    )
  end

  context 'with valid params' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(
        intitule: 'Updated title',
        description: 'Updated description'
      )
    end

    it { is_expected.to be_success }

    it 'updates the instructor draft request' do
      expect {
        organizer
      }.not_to change(InstructorDraftRequest, :count)

      instructor_draft_request.reload

      expect(instructor_draft_request.data).to eq({
        'intitule' => 'Updated title',
        'description' => 'Updated description'
      })
    end

    it 'does not create an authorization request' do
      expect {
        organizer
      }.not_to change(AuthorizationRequest, :count)
    end
  end

  context 'with no authorization request param' do
    let(:authorization_request_params) do
      ActionController::Parameters.new
    end

    it { is_expected.to be_a_failure }

    it 'does not update the authorization request draft' do
      original_data = instructor_draft_request.data.dup

      expect {
        organizer
      }.not_to change(InstructorDraftRequest, :count)

      instructor_draft_request.reload
      expect(instructor_draft_request.data).to eq(original_data)
    end
  end

  context 'with partial authorization request params' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(
        intitule: 'Only title updated'
      )
    end

    it { is_expected.to be_a_success }

    it 'updates only the provided fields' do
      expect {
        organizer
      }.not_to change(InstructorDraftRequest, :count)

      instructor_draft_request.reload

      expect(instructor_draft_request.data).to eq({
        'intitule' => 'Only title updated',
        'description' => 'Original description'
      })
    end
  end

  context 'with invalid authorization request params (updating a draft)' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(
        contact_metier_email: 'invalid_email',
        intitule: 'Updated with invalid data'
      )
    end

    it { is_expected.to be_a_success }

    it 'updates the instructor draft request even with invalid data' do
      expect {
        organizer
      }.not_to change(InstructorDraftRequest, :count)

      instructor_draft_request.reload

      expect(instructor_draft_request.data).to include({
        'contact_metier_email' => 'invalid_email',
        'intitule' => 'Updated with invalid data'
      })
    end

    it 'does not create an authorization request' do
      expect {
        organizer
      }.not_to change(AuthorizationRequest, :count)
    end
  end

  context 'with files' do
    let!(:instructor_draft_request) do
      create(
        :instructor_draft_request,
        :with_documents,
        instructor:,
        authorization_request_class: 'AuthorizationRequest::APIEntreprise',
        data: { 'intitule' => 'Original title' }
      )
    end
    let(:existing_signed_id) { instructor_draft_request.documents.first.files.first.signed_id }
    let(:filenames) { instructor_draft_request.reload.documents.flat_map { |document| document.files.map { |file| file.filename.to_s } } }

    context 'when a file is added on a later save' do
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          intitule: 'Updated title',
          cadre_juridique_document: ['', fixture_file_upload('spec/fixtures/another_dummy.pdf', 'application/pdf')]
        )
      end

      it 'stores the new file and drops the one not resubmitted' do
        expect(organizer).to be_success
        expect(filenames).to eq(['another_dummy.pdf'])
      end
    end

    context 'when the existing file is kept through its signed id' do
      let(:authorization_request_params) do
        ActionController::Parameters.new(
          intitule: 'Updated title',
          cadre_juridique_document: ['', existing_signed_id, fixture_file_upload('spec/fixtures/another_dummy.pdf', 'application/pdf')]
        )
      end

      it 'keeps both files in a single document' do
        expect { organizer }.not_to change(InstructorDraftRequestDocument, :count)
        expect(filenames).to contain_exactly('dummy.pdf', 'another_dummy.pdf')
      end
    end

    context 'when only the sentinel is submitted' do
      let(:authorization_request_params) do
        ActionController::Parameters.new(intitule: 'Updated title', cadre_juridique_document: [''])
      end

      it 'removes the file' do
        expect(organizer).to be_success
        expect(filenames).to be_empty
      end
    end
  end
end
