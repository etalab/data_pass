require 'rails_helper'

RSpec.describe CreateInstructorDraftRequest, type: :organizer do
  subject(:organizer) { described_class.call(params) }

  let(:params) do
    {
      authorization_request_params:,
      instructor_draft_request_params:,
      instructor:,
    }
  end
  let(:instructor) { create(:user, :instructor) }
  let(:instructor_draft_request_params) do
    {
      authorization_request_class: 'AuthorizationRequest::APIEntreprise',
      comment: 'Some comments',
    }
  end

  context 'with valid params' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(
        intitule: 'My draft'
      )
    end

    it { is_expected.to be_success }

    it 'creates an instructor draft request' do
      expect {
        organizer
      }.to change(InstructorDraftRequest, :count).by(1)

      instructor_draft_request = organizer.instructor_draft_request

      expect(instructor_draft_request.instructor).to eq(instructor)
      expect(instructor_draft_request.authorization_request_class).to eq('AuthorizationRequest::APIEntreprise')
      expect(instructor_draft_request.comment).to eq('Some comments')
      expect(instructor_draft_request.data).to eq({
        'intitule' => 'My draft'
      })
    end

    it 'does not create an authorization request' do
      expect {
        organizer
      }.not_to change(AuthorizationRequest, :count)
    end
  end

  context 'with params including files' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(
        intitule: 'My draft',
        maquette_projet: [
          fixture_file_upload('spec/fixtures/dummy.pdf', 'application/pdf'),
        ]
      )
    end

    it { is_expected.to be_success }

    it 'creates an instructor draft request with files' do
      expect {
        organizer
      }.to change(InstructorDraftRequest, :count).by(1)

      instructor_draft_request = organizer.instructor_draft_request

      document = instructor_draft_request.documents.first

      expect(document.files.count).to eq(1)
      expect(document.files.first.filename.to_s).to eq('dummy.pdf')
    end
  end

  context 'with no authorization request param' do
    let(:authorization_request_params) do
      ActionController::Parameters.new
    end

    it { is_expected.to be_a_failure }

    it 'does not create an authorization request draft' do
      expect {
        organizer
      }.not_to change(InstructorDraftRequest, :count)
    end
  end

  context 'with invalid authorization request params (first creation, still a draft)' do
    let(:authorization_request_params) do
      ActionController::Parameters.new(contact_metier_email: 'invalid_email')
    end

    it { is_expected.to be_a_success }

    it 'creates an instructor draft request' do
      expect {
        organizer
      }.to change(InstructorDraftRequest, :count).by(1)
    end

    it 'does not create an authorization request' do
      expect {
        organizer
      }.not_to change(AuthorizationRequest, :count)
    end
  end
end
