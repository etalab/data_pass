class StartNextAuthorizationRequestStage < ApplicationOrganizer
  include TransactionalOrganizer

  before do
    context.state_machine_event = :start_next_stage
  end

  organize ExecuteAuthorizationRequestTransitionWithCallbacks,
    AssignLatestProductionDataInAuthorizationRequest
end
