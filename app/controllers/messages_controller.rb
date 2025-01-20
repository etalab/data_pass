class MessagesController < AuthenticatedUserController
  before_action :extract_authorization_request
  before_action :mark_messages_as_read!, only: [:index]

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
        format.html { redirect_to authorization_request_messages_path(@authorization_request) }
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

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end
end
