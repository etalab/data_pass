require 'rails_helper'

RSpec.describe AuthorizationRequestInstructorDraftMailer do
  describe '#invite_applicant' do
    subject(:mail) do
      described_class.with(
        authorization_request_instructor_draft:,
      ).invite_applicant
    end

    let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
    let!(:reporter) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }
    let!(:foreign_reporter) { create(:user, :reporter, authorization_request_types: %w[api_particulier]) }

    let(:authorization_request_instructor_draft) do
      create(:authorization_request_instructor_draft, :with_applicant, instructor:)
    end

    it 'sends the email to the applicant and bcc instructors and reporters related to this authorization definition' do
      expect(mail.to).to eq([authorization_request_instructor_draft.applicant.email])
      expect(mail.bcc).to eq([instructor.email, reporter.email])
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
