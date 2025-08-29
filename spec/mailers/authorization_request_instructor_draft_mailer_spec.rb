require 'rails_helper'

RSpec.describe AuthorizationRequestInstructorDraftMailer do
  describe '#invite_applicant' do
    subject(:mail) do
      described_class.with(
        authorization_request_instructor_draft:,
      ).invite_applicant
    end

    let(:instructor) { create(:user, :instructor) }
    let(:authorization_request_instructor_draft) do
      create(:authorization_request_instructor_draft, :with_applicant, instructor:)
    end

    it 'sends the email to the applicant and cc instructor' do
      expect(mail.to).to eq([authorization_request_instructor_draft.applicant.email])
      expect(mail.cc).to eq([instructor.email])
    end

    it 'includes the project name in the subject' do
      expect(mail.subject).to include(authorization_request_instructor_draft.project_name)
    end

    it 'includes the claim link in the body' do
      expect(mail.body.encoded).to include(
        claim_authorization_request_instructor_draft_path(authorization_request_instructor_draft.public_id)
      )
    end

    it 'includes the project name in the body' do
      expect(mail.body.encoded).to include(authorization_request_instructor_draft.project_name)
    end
  end
end
