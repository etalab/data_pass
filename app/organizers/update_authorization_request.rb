class UpdateAuthorizationRequest < ApplicationOrganizer
  before do
    context.event_name = 'update'
    context.save_context ||= :update
  end

  organize UpdateAuthorizationRequestModel,
    AfterUpdateAuthorizationRequest
end
