class RedirectFromV1Controller < ApplicationController
  def show
    redirect_to authorization_path(Authorization.find(params[:id]).slug),
      status: :moved_permanently
  rescue ActiveRecord::RecordNotFound
    redirect_to authorization_request_path(AuthorizationRequest.find(params[:id])),
      status: :moved_permanently
  end
end
