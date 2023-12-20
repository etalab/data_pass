class Instruction::AuthorizationRequestsController < InstructionController
  before_action :extract_authorization_request, except: [:index]

  def index
    @authorization_requests = policy_scope([:instruction, AuthorizationRequest]).page(params[:page])
  end

  def show
    authorize [:instruction, @authorization_request]

    render_show
  end

  def refuse
    authorize [:instruction, @authorization_request]

    if @authorization_request.refuse
      success_message(title: t('.success', name: @authorization_request.name))

      redirect_to instruction_authorization_requests_path
    else
      render_show
    end
  end

  def approve
    authorize [:instruction, @authorization_request]

    if @authorization_request.approve
      success_message(title: t('.success', name: @authorization_request.name))

      redirect_to instruction_authorization_requests_path
    else
      render_show
    end
  end

  private

  def render_show
    if @authorization_request.form.multiple_steps?
      render 'show'
    else
      render "instruction/authorization_requests/show/#{@authorization_request.form.uid.underscore}"
    end
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id])
  end
end
