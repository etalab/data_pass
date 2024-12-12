class AuthorizationRequestPreview < ActionMailer::Preview
  {
    changes_requested: :request_changes,
    refused: :refuse,
    revoked: :revoke,
    validated: :approve
  }.each do |state, event|
    [event, "reopening_#{event}"].each do |mth|
      next if mth == 'reopening_revoke'

      define_method mth do
        authorization_request_mailer_method(state, mth)
      end
    end
  end

  def approve_dgfip_sandbox
    AuthorizationRequestMailer.with(
      authorization_request: AuthorizationRequest::APIImpotParticulierSandbox.where(state: :validated).first
    ).approve
  end

  private

  def authorization_request_mailer_method(state, mth)
    AuthorizationRequestMailer.with(
      authorization_request: AuthorizationRequest.where(state:).first
    ).public_send(mth)
  end
end
