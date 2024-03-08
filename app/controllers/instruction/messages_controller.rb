class Instruction::MessagesController < InstructionController
  before_action :extract_authorization_request
  before_action :mark_messages_as_read!, only: [:index]

  def index
    authorize [:instruction, @authorization_request], :show?

    extract_messages
    @message = Message.new
  end

  def create
    authorize [:instruction, @authorization_request], :send_message?

    @organizer = SendMessageToApplicant.call(
      authorization_request: @authorization_request,
      user: current_user,
      message_params:,
    )

    if @organizer.success?
      success_message(title: t('.success'))

      redirect_to instruction_authorization_request_messages_path(@authorization_request),
        status: :see_other
    else
      extract_messages
      @message = @organizer.message

      render 'index'
    end
  end

  private

  def message_params
    params.require(:message).permit(
      :body,
    )
  end

  def extract_messages
    @messages = @authorization_request.messages.includes([:from]).order(created_at: :desc)
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def mark_messages_as_read!
    @authorization_request.mark_messages_as_read_by_instructors!
  end

  def layout_name
    'instruction/authorization_request'
  end
end
