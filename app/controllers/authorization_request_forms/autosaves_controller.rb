class AuthorizationRequestForms::AutosavesController < AuthorizationRequestFormsController
  def update
    authorize @authorization_request, :autosave?

    if save_draft.success?
      render :update, formats: :turbo_stream
    else
      head :unprocessable_content
    end
  end

  private

  def save_draft
    UpdateAuthorizationRequestModel.call(
      authorization_request: @authorization_request,
      authorization_request_params:,
      user: current_user,
      save_context: :save_within_wizard
    )
  end

  def extract_authorization_request
    @authorization_request = authorization_request_class.find(params.expect(:authorization_request_id)).decorate
  end

  def user_not_authorized
    head :forbidden
  end

  def redirect_to_sign_in
    head :unauthorized
  end
end
