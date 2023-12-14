class AuthorizationRequests::BuildController < AuthorizationRequestsController
  include Wicked::Wizard

  prepend_before_action :configure_steps

  def show
    authorize @authorization_request, :show?

    jump_to(:finish) if should_redirect_to_finish_page?

    render_wizard
  end

  def update
    if final_submit?
      submit
    else
      authorize @authorization_request, :update?

      if @authorization_request.update(authorization_request_params)
        redirect_to next_wizard_path
      else
        error_message(title: t('.error.title'), description: t('.error.description'))

        render_wizard(@authorization_request, status: :unprocessable_entity)
      end
    end
  end

  private

  def should_redirect_to_finish_page?
    !@authorization_request.in_draft? &&
      step != 'finish'
  end

  def authorization_request_params
    super.merge(current_build_step: params[:id])
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def configure_steps
    extract_authorization_request_form

    self.steps = @authorization_request_form.steps.pluck(:name) + %w[finish]
  end
end
