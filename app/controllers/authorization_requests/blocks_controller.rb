class AuthorizationRequests::BlocksController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsFlashes

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
      success_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.update')

      redirect_to summary_authorization_request_form_path(form_uid: @authorization_request.form.uid, id: @authorization_request.id)
    else
      error_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.update')

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

  def layout_name
    'authorization_request'
  end
end
