class StartNextAuthorizationRequestStage < ApplicationOrganizer
  before do
    context.state_machine_event = :start_next_stage
  end

  organize ExecuteAuthorizationRequestTransitionWithCallbacks
end
