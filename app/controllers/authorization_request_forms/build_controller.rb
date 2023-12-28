class AuthorizationRequestForms::BuildController < AuthorizationRequestFormsController
  include Wicked::Wizard::Translated

  prepend_before_action :configure_steps

  def show
    authorize @authorization_request, :show?

    jump_to(t('wicked.finish')) if should_redirect_to_finish_page?

    render_wizard
  end

  def update
    if final_submit?
      submit
    else
      authorize @authorization_request, :update?

      organizer = organizer_for_update

      @authorization_request = organizer.authorization_request

      if organizer.success?
        redirect_to next_wizard_path
      else
        error_message(title: t('.error.title'), description: t('.error.description'))

        render_wizard(@authorization_request, status: :unprocessable_entity)
      end
    end
  end

  private

  def authorization_request_params
    super.merge(current_build_step: wizard_value(params[:id]))
  end

  def should_redirect_to_finish_page?
    !@authorization_request.in_draft? &&
      wizard_value(step) != 'finish'
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def configure_steps
    extract_authorization_request_form

    self.steps = @authorization_request_form.steps.pluck(:name) + %w[finish]
  end
end
