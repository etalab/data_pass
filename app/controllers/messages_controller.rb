class MessagesController < AuthenticatedUserController
  helper DemandesHabilitations::CommonHelper

  before_action :extract_authorization_or_request
  before_action :mark_messages_as_read!, only: [:index]
  decorates_assigned :authorization_request, :authorization

  def index
    authorize @authorization_request, :messages?

    build_models
  end

  def create
    authorize @authorization_request, :send_message?

    @organizer = SendMessageToInstructors.call(
      authorization_request: @authorization_request,
      user: current_user,
      message_params:,
    )

    if @organizer.success?
      build_models

      respond_to do |format|
        format.html { redirect_to messages_index_path }
        format.turbo_stream
      end
    else
      render :index
    end
  end

  private

  def mark_messages_as_read!
    @authorization_request.mark_messages_as_read_by_applicant!
  end

  def build_models
    @messages = @authorization_request.messages.includes([:from]).order(created_at: :desc)
    @message = Message.new
  end

  def message_params
    params.expect(
      message: [:body],
    )
  end

  def extract_authorization_or_request
    if params[:authorization_id].present?
      @authorization = Authorization.friendly.find(params[:authorization_id])
      @authorization_request = @authorization.request
    else
      @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
    end
  end

  def model_to_track_for_impersonation
    @organizer&.message || @message
  end

  def layout_name
    return 'authorization_with_tabs' if @authorization.present?

    'authorization_request_with_tabs'
  end

  def messages_index_path
    return authorization_messages_path(@authorization) if @authorization.present?

    authorization_request_messages_path(@authorization_request)
  end
end
