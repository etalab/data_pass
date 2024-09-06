class Public::AuthorizationRequestsController < PublicController
  helper AuthorizationRequestsHelpers

  helper_method :current_user, :user_signed_in?

  def show
    @authorization_request = AuthorizationRequest.find_by(public_id: params[:id])

    if @authorization_request
      @authorization_request = @authorization_request.decorate

      render 'authorization_request_forms/summary', layout: 'authorization_request'
    else
      redirect_to root_path
    end
  end
end
