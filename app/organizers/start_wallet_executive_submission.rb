class StartWalletExecutiveSubmission < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.save_context = :submit
  end

  organize AssignParamsToAuthorizationRequest

  after do
    context.authorization_request.save!(validate: false)
    context.submission_intent = WalletRegistry::SubmissionIntent.issue(authorization_request: context.authorization_request, user: context.user)
  end
end
