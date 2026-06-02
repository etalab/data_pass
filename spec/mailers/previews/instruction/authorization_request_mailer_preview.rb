class Instruction::AuthorizationRequestMailerPreview < ActionMailer::Preview
  def submit
    Instruction::AuthorizationRequestMailer.with(
      authorization_request: authorization_request
    ).submit
  end

  def reopening_submit
    Instruction::AuthorizationRequestMailer.with(
      authorization_request: reopened_authorization_request
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
end
