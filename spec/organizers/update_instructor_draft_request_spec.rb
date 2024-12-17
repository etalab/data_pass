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
end
