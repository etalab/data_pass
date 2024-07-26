class AuthorizationRequestForms::BuildController < AuthorizationRequestFormsController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsHelpers

  include Wicked::Wizard::Translated

  prepend_before_action :configure_steps

  def show
    authorize @authorization_request, :show?

    render_wizard
  end

  def update
    if final_submit?
      submit
    else
      authorize @authorization_request, :update?

      organizer = organizer_for_update

      @authorization_request = organizer.authorization_request

      if organizer.success? && save_only?
        save_only
      elsif organizer.success?
        save_and_continue
      else
        error_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.build.update')

        render_wizard(@authorization_request, status: :unprocessable_entity)
      end
    end
  end

  private

  def save_only
    success_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.update')

    redirect_to wizard_path
  end

  def save_and_continue
    save_current_step

    redirect_to next_wizard_path
  end

  def authorization_request_params
    super.merge(current_build_step: wizard_value(params[:id]))
  end

  def update_save_context
    if save_only?
      :save_within_wizard
    else
      super
    end
  end

  def save_current_step
    session[current_build_step_cache_key] = next_step
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id]).decorate
  end

  def configure_steps
    extract_authorization_request_form

    self.steps = @authorization_request_form.steps.pluck(:name)
  end

  def finish_wizard_path
    summary_authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
  end

  def save_only?
    params.key?(:save)
  end
end
