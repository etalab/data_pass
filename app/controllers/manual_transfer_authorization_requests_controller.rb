class ManualTransferAuthorizationRequestsController < AuthenticatedUserController
  before_action :extract_authorization_request
  before_action :authorize_authorization_request_transfer

  def new; end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def authorize_authorization_request_transfer
    authorize @authorization_request, :manual_transfer_from_instructor?
  end
end
