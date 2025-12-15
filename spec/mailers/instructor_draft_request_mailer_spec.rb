require 'rails_helper'

RSpec.describe InstructorDraftRequestMailer do
  describe '#invite_applicant' do
    subject(:mail) do
      described_class.with(
        instructor_draft_request:,
      ).invite_applicant
    end

    let!(:instructor) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }
    let!(:reporter) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }
    let!(:foreign_reporter) { create(:user, :reporter, authorization_request_types: %w[api_particulier]) }

    let(:instructor_draft_request) do
      create(:instructor_draft_request, :with_applicant, instructor:)
    end

    it 'sends the email to the applicant and bcc instructors and reporters related to this authorization definition' do
      expect(mail.to).to eq([instructor_draft_request.applicant.email])
      expect(mail.bcc).to eq([instructor.email, reporter.email])
    end

    it 'includes the project name in the subject' do
      expect(mail.subject).to include(instructor_draft_request.project_name)
    end

    it 'includes the claim link in the body' do
      expect(mail.body.encoded).to include(
        claim_instructor_draft_request_path(instructor_draft_request.public_id)
      )
    end

    it 'includes the project name in the body' do
      expect(mail.body.encoded).to include(instructor_draft_request.project_name)
    end
  end
end
