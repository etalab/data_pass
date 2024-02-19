class ArchiveAuthorizationRequest < ApplicationOrganizer
  before do
    context.state_machine_event = :archive
  end

  organize TriggerAuthorizationRequestEvent,
    CreateAuthorizationRequestEventModel
end
