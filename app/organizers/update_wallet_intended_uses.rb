class UpdateWalletIntendedUses < ApplicationOrganizer
  before do
    context.save_context = :save_within_wizard
  end

  organize AssignParamsToAuthorizationRequest,
    ApplyWalletIntendedUseCommand,
    SaveAuthorizationRequest
end
