require 'rails_helper'

RSpec.describe ClaimInstructorDraftRequest, type: :organizer do
  subject(:organizer) { described_class.call(params) }

  let(:params) do
    {
      instructor_draft_request:,
    }
  end

  let!(:instructor_draft_request) do
    create(:instructor_draft_request, :complete, organization:, claimed: false, data: { 'intitule' => 'Test Project' })
  end

  let(:organization) { create(:organization) }
  let(:user) { instructor_draft_request.applicant }

  context 'with valid params' do
    it { is_expected.to be_success }

    it 'creates an authorization request' do
      expect {
        organizer
      }.to change(AuthorizationRequest, :count).by(1)

      authorization_request = organizer.authorization_request
      expect(authorization_request.applicant).to eq(instructor_draft_request.applicant)
      expect(authorization_request.organization).to eq(instructor_draft_request.organization)
      expect(authorization_request.data['intitule']).to eq('Test Project')
      expect(authorization_request.state).to eq('draft')
    end

    it 'marks the draft as claimed' do
      expect {
        organizer
      }.to change { instructor_draft_request.reload.claimed }.from(false).to(true)
    end

    it 'creates a claim event' do
      expect {
        organizer
      }.to change(AuthorizationRequestEvent, :count).by(1)

      event = organizer.authorization_request_event
      expect(event.name).to eq('claim')
      expect(event.entity).to eq(instructor_draft_request)
      expect(event.user).to eq(user)
      expect(event.authorization_request).to eq(organizer.authorization_request)
    end

    it 'adds user to organization if not already a member' do
      expect(user.organizations).not_to include(organization)

      organizer

      expect(user.reload.organizations).to include(organization)

      org_user = user.organizations_users.find_by(organization:)

      expect(org_user.verified).to be(false)
      expect(org_user.identity_federator).to eq('unknown')
      expect(org_user.identity_provider_uid).to be_nil
    end

    context 'when user is already a member of the organization' do
      before do
        user.add_to_organization(organization, verified: true, identity_federator: 'pro_connect', identity_provider_uid: 'some-uid')
      end

      it 'does not modify the existing organization membership' do
        organizer

        org_user = user.organizations_users.find_by(organization:)
        expect(org_user.verified).to be(true)
        expect(org_user.identity_federator).to eq('pro_connect')
        expect(org_user.identity_provider_uid).to eq('some-uid')
      end
    end
  end

  context 'when draft has documents' do
    let(:instructor_draft_request) do
      create(:instructor_draft_request, :complete, :with_documents, claimed: false)
    end

    it 'copies documents from draft to authorization request' do
      organizer

      authorization_request = organizer.authorization_request
      draft_document = instructor_draft_request.documents.first

      expect(authorization_request.public_send(draft_document.identifier)).to be_attached
      expect(authorization_request.public_send(draft_document.identifier).count).to eq(draft_document.files.count)
    end
  end

  context 'when draft is already claimed' do
    before do
      instructor_draft_request.update!(claimed: true)
    end

    it { is_expected.to be_failure }

    it 'does not create an authorization request' do
      expect {
        organizer
      }.not_to change(AuthorizationRequest, :count)
    end

    it 'fails with appropriate error message' do
      expect(organizer.error).to eq(:draft_already_claimed)
    end
  end
end
