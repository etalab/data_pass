class AuthorizationRequestForms::BuildController < AuthorizationRequestFormsController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsHelpers

  include Wicked::Wizard::Translated

  rescue_from Wicked::Wizard::InvalidStepError do
    raise ActiveRecord::RecordNotFound
  end

  prepend_before_action :configure_steps

  def show
    authorize @authorization_request, :show?
    copy_loaded_identity

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

        render_wizard(@authorization_request, status: :unprocessable_content)
      end
    end
  end

  private

  def copy_loaded_identity
    return unless policy(@authorization_request).refresh_identity?

    @authorization_request.object.copy_loaded_identity!
  end

  def save_only
    return show_set_aside_values if @authorization_request.draft_set_aside_values.any?

    success_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.update', tiny: true)

    redirect_to wizard_path
  end

  def show_set_aside_values
    set_aside_values_message(@authorization_request, now: true)
    @authorization_request.reveal_draft_set_aside_values!

    render_wizard(nil, status: :unprocessable_content)
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
    cookies[current_build_step_cache_key] = { value: next_step, expires: 7.days.from_now }
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params.expect(:authorization_request_id)).decorate
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
