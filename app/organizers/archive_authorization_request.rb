class ArchiveAuthorizationRequest < ApplicationOrganizer
  include TransactionalOrganizer

  before do
    context.state_machine_event = :archive
  end

  organize ExecuteAuthorizationRequestTransitionWithCallbacks
end
