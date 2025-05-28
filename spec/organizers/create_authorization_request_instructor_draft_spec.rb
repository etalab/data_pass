require 'rails_helper'

RSpec.describe CreateAuthorizationRequestInstructorDraft, type: :organizer do
  subject(:organizer) { described_class.call(params) }

  let(:params) do
    {
      authorization_request_params:,
      authorization_request_instructor_draft_params:,
      instructor:,
    }
  end
  let(:instructor) { create(:user, :instructor) }
  let(:authorization_request_instructor_draft_params) do
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

    it 'creates an authorization request instructor draft' do
      expect {
        organizer
      }.to change(AuthorizationRequestInstructorDraft, :count).by(1)

      authorization_request_instructor_draft = organizer.authorization_request_instructor_draft

      expect(authorization_request_instructor_draft.instructor).to eq(instructor)
      expect(authorization_request_instructor_draft.authorization_request_class).to eq('AuthorizationRequest::APIEntreprise')
      expect(authorization_request_instructor_draft.comment).to eq('Some comments')
      expect(authorization_request_instructor_draft.data).to eq({
        'intitule' => 'My draft'
      })
    end

    it 'does not create an authorization request' do
      expect {
        organizer
      }.not_to change(AuthorizationRequest, :count)
    end
  end

  context 'with invalid params' do
    let(:authorization_request_params) do
      ActionController::Parameters.new
    end

    it { is_expected.to be_a_failure }

    it 'does not create an authorization request draft' do
      expect {
        organizer
      }.not_to change(AuthorizationRequestInstructorDraft, :count)
    end
  end
end
