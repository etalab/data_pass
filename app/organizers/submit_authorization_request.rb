class SubmitAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.state_machine_event = :submit
    context.event_entity = :changelog
    context.save_context ||= :submit
  end

  organize AssignParamsToAuthorizationRequest,
    CreateAuthorizationRequestChangelog,
    ExecuteAuthorizationRequestTransitionWithCallbacks,
    RunMalwareScanOnDocuments

  after do
    context.authorization_request.save(context: context.save_context) ||
      context.fail!
  end
end
