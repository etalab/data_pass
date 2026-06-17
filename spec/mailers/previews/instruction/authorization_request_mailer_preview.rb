class Instruction::AuthorizationRequestMailerPreview < ActionMailer::Preview
  def submit
    Instruction::AuthorizationRequestMailer.with(
      authorization_request:,
      user: instructor,
    ).submit
  end

  def reopening_submit
    Instruction::AuthorizationRequestMailer.with(
      authorization_request: reopened_authorization_request,
      user: instructor,
    ).reopening_submit
  end

  private

  def authorization_request
    AuthorizationRequest.where(state: :submitted).first
  end

  def reopened_authorization_request
    AuthorizationRequest.where(state: :submitted).where.not(reopened_at: nil).first ||
      authorization_request
  end

  def instructor
    authorization_request.definition.instructors_or_reporters.first ||
      User.with_role_for_definition(:reporter, authorization_request.definition).first
  end
end
