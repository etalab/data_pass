class AuthorizationRequestPreview < ActionMailer::Preview
  %w[changes_requested refused revoked validated].each do |state|
    [state, "reopening_#{state}"].each do |mth|
      define_method mth do
        authorization_request_mailer_method(state, mth)
      end
    end
  end

  private

  def authorization_request_mailer_method(state, mth)
    AuthorizationRequestMailer.with(
      authorization_request: AuthorizationRequest.where(state:).first
    ).public_send(mth)
  end
end
