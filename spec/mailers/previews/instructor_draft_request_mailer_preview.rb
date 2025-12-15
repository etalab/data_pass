class InstructorDraftRequestMailerPreview < ActionMailer::Preview
  def invite_applicant
    InstructorDraftRequestMailer.with(
      instructor_draft_request: instructor_draft_request
    ).invite_applicant
  end

  private

  def instructor_draft_request
    InstructorDraftRequest.joins(:applicant, :organization).last
  end
end
