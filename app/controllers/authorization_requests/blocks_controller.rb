class AuthorizationRequests::BlocksController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  before_action :extract_authorization_request
  before_action :validate_block_id

  helper_method :block_id

  def edit; end

  def update
    organizer = ReviewAuthorizationRequest.call(
      authorization_request: @authorization_request,
      authorization_request_params:,
      user: current_user,
    )

    if organizer.success?
      success_message(title: t('authorization_request_forms.update.success', name: @authorization_request.name))

      redirect_to summary_authorization_request_form_path(form_uid: @authorization_request.form.uid, id: @authorization_request.id)
    else
      error_message(title: t('authorization_request_forms.update.error.title'), description: t('authorization_request_forms.update.error.description'))

      render :edit, status: :unprocessable_entity
    end
  end

  private

  def authorization_request_params
    params.require(@authorization_request.object.class.model_name.singular)
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id]).decorate

    authorize @authorization_request, :update?
  end

  def block_id
    params[:id]
  end

  def validate_block_id
    return if @authorization_request.editable_blocks.pluck(:name).include?(params[:id])

    raise ActiveRecord::RecordNotFound
  end
end
