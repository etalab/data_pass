require 'rails_helper'

RSpec.describe ClaimAuthorizationRequestInstructorDraft, type: :organizer do
  subject(:organizer) { described_class.call(params) }

  let(:params) do
    {
      authorization_request_instructor_draft:,
    }
  end

  let!(:authorization_request_instructor_draft) do
    create(:authorization_request_instructor_draft, :complete, organization:, claimed: false, data: { 'intitule' => 'Test Project' })
  end

  let(:organization) { create(:organization) }
  let(:user) { authorization_request_instructor_draft.applicant }

  context 'with valid params' do
    it { is_expected.to be_success }

    it 'creates an authorization request' do
      expect {
        organizer
      }.to change(AuthorizationRequest, :count).by(1)

      authorization_request = organizer.authorization_request
      expect(authorization_request.applicant).to eq(authorization_request_instructor_draft.applicant)
      expect(authorization_request.organization).to eq(authorization_request_instructor_draft.organization)
      expect(authorization_request.data).to eq({ 'intitule' => 'Test Project' })
      expect(authorization_request.state).to eq('draft')
    end

    it 'marks the draft as claimed' do
      expect {
        organizer
      }.to change { authorization_request_instructor_draft.reload.claimed }.from(false).to(true)
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
    let(:authorization_request_instructor_draft) do
      create(:authorization_request_instructor_draft, :complete, :with_documents, claimed: false)
    end

    it 'copies documents from draft to authorization request' do
      organizer

      authorization_request = organizer.authorization_request
      draft_document = authorization_request_instructor_draft.documents.first

      expect(authorization_request.public_send(draft_document.identifier)).to be_attached
      expect(authorization_request.public_send(draft_document.identifier).count).to eq(draft_document.files.count)
    end
  end

  context 'when draft is already claimed' do
    before do
      authorization_request_instructor_draft.update!(claimed: true)
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
