require 'rails_helper'

RSpec.describe UpdateAuthorizationRequestInstructorDraft, type: :organizer do
  subject(:organizer) { described_class.call(params) }

  let(:params) do
    {
      authorization_request_instructor_draft:,
      authorization_request_params:,
    }
  end
  let!(:instructor) { create(:user, :instructor) }
  let!(:authorization_request_instructor_draft) do
    create(
      :authorization_request_instructor_draft,
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

    it 'updates the authorization request instructor draft' do
      expect {
        organizer
      }.not_to change(AuthorizationRequestInstructorDraft, :count)

      authorization_request_instructor_draft.reload

      expect(authorization_request_instructor_draft.data).to eq({
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
      original_data = authorization_request_instructor_draft.data.dup

      expect {
        organizer
      }.not_to change(AuthorizationRequestInstructorDraft, :count)

      authorization_request_instructor_draft.reload
      expect(authorization_request_instructor_draft.data).to eq(original_data)
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
      }.not_to change(AuthorizationRequestInstructorDraft, :count)

      authorization_request_instructor_draft.reload

      expect(authorization_request_instructor_draft.data).to eq({
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

    it 'updates the authorization request instructor draft even with invalid data' do
      expect {
        organizer
      }.not_to change(AuthorizationRequestInstructorDraft, :count)

      authorization_request_instructor_draft.reload

      expect(authorization_request_instructor_draft.data).to include({
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
