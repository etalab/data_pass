class Instruction::AuthorizationRequestsController < InstructionController
  helper AuthorizationRequestsHelpers

  before_action :extract_authorization_request, except: [:index]

  def index
    @authorization_requests = policy_scope([:instruction, AuthorizationRequest]).page(params[:page])
  end

  def show
    authorize [:instruction, @authorization_request]

    render_show
  end

  private

  def render_show
    if @authorization_request.form.multiple_steps?
      render 'show', layout: 'instruction/authorization_request'
    else
      render "authorization_request_forms/#{@authorization_request.form.uid.underscore}", layout: 'instruction/authorization_request'

    end
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id])
  end
end
