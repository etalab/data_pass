# rubocop:disable Metrics/ClassLength
class AuthorizationRequestFormsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsFlashes

  allow_unauthenticated_access only: [:new]

  before_action :extract_authorization_request_form
  before_action :extract_authorization_request, only: %i[show summary update]

  def new
    authorize @authorization_request_form, :new?
    @authorization_definition = @authorization_request_form.authorization_definition

    if user_signed_in?
      render 'authorization_request_forms/new', layout: 'form_introduction'
    else
      save_redirect_path
      render 'authorization_requests/unauthenticated_start'
    end
  end

  def start
    @authorization_request = BuildAuthorizationRequest.call(
      authorization_request_form: @authorization_request_form,
      applicant: current_user,
    ).authorization_request.decorate

    render view_path
  end

  def create
    authorize @authorization_request_form, :create?

    if @authorization_request_form.multiple_steps?
      create_for_multiple_steps
    else
      create_for_single_page_form
    end
  end

  def show
    authorize @authorization_request

    if @authorization_request.reopening?
      redirect_to summary_authorization_request_form_path(form_uid: @authorization_request.form.uid, id: @authorization_request.id)
    elsif @authorization_request_form.multiple_steps?
      redirect_to_current_build_step
    else
      render view_path
    end
  rescue Pundit::NotAuthorizedError
    redirect_to summary_authorization_request_form_path(form_uid: @authorization_request_form.uid, id: @authorization_request.id)
  end

  def update
    if final_submit?
      submit
    elsif review?
      go_to_summary
    else
      update_model
    end
  end

  def summary
    authorize @authorization_request

    flash.keep if turbo_request?

    @summary_before_submit = @authorization_request.filling?
  rescue Pundit::NotAuthorizedError
    redirect_on_unauthorized_summary
  end

  private

  def redirect_on_unauthorized_summary
    flash.keep

    if AuthorizationRequestPolicy.new(pundit_user, @authorization_request).show?
      redirect_to authorization_request_form_path(form_uid: @authorization_request_form.uid, id: @authorization_request.id)
    elsif Instruction::AuthorizationRequestPolicy.new(pundit_user, @authorization_request).show?
      redirect_to instruction_authorization_request_path(@authorization_request)
    else
      raise
    end
  end

  # rubocop:disable Metrics/AbcSize
  def create_for_multiple_steps
    organizer = organizer_for_creation

    @authorization_request = organizer.authorization_request.decorate

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.create')

      redirect_to authorization_request_form_build_path(
        form_uid: @authorization_request.form_uid,
        authorization_request_id: @authorization_request.id,
        id: next_step_localized,
      )
    else
      error_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.build.update')

      render view_path(@authorization_request.form.steps.first[:name]),
        status: :unprocessable_entity
    end
  end

  # rubocop:enable Metrics/AbcSize

  def next_step_localized
    t("wicked.#{next_submit? ? authorization_request_steps_names[1] : authorization_request_steps_names[0]}")
  end

  def authorization_request_steps_names
    @authorization_request_form.steps.pluck(:name)
  end

  def build_step_for_create
    next_submit? ? authorization_request_steps_names.first : nil
  end

  def redirect_to_current_build_step
    step = session.fetch(current_build_step_cache_key, t("wicked.#{@authorization_request_form.steps.first[:name]}"))

    redirect_to authorization_request_form_build_path(
      form_uid: @authorization_request_form.uid,
      authorization_request_id: @authorization_request.id,
      id: step,
    )
  end

  def current_build_step_cache_key
    "authorization_request_form:#{@authorization_request.id}:current_build_step"
  end

  def create_for_single_page_form
    organizer = organizer_for_creation

    @authorization_request = organizer.authorization_request.decorate

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.create')

      redirect_to authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
    else
      error_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.create_for_single_page_form')

      render view_path, status: :unprocessable_entity
    end
  end

  def organizer_for_creation
    authorization_request_create_params = if @authorization_request_form.multiple_steps?
                                            authorization_request_params.merge(current_build_step: build_step_for_create)
                                          else
                                            authorization_request_params
                                          end

    CreateAuthorizationRequest.call(
      user: current_user,
      authorization_request_form: @authorization_request_form,
      authorization_request_params: authorization_request_create_params,
    )
  end

  def update_model
    authorize @authorization_request, :update?

    organizer = organizer_for_update

    @authorization_request = organizer.authorization_request

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.update')

      redirect_to authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
    else
      error_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.update')

      render view_path, status: :unprocessable_entity
    end
  end

  def organizer_for_update
    UpdateAuthorizationRequest.call(
      authorization_request: @authorization_request,
      authorization_request_params:,
      user: current_user,
      save_context: update_save_context,
    )
  end

  def update_save_context
    :update
  end

  def go_to_summary
    authorize @authorization_request, :show?

    if review_authorization_request.success?
      redirect_to summary_authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
    else
      error_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.update')

      render view_path, status: :unprocessable_entity
    end
  end

  def submit
    authorize @authorization_request, :submit?

    organizer = SubmitAuthorizationRequest.call(
      authorization_request: @authorization_request,
      authorization_request_params:,
      user: current_user,
    )

    @authorization_request = organizer.authorization_request

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.submit')

      redirect_to dashboard_path
    else
      error_message_for_authorization_request(@authorization_request, key: 'authorization_request_forms.submit', include_model_errors: true)

      render 'summary', status: :unprocessable_entity
    end
  end

  def final_submit?
    params.key?(:submit)
  end

  def next_submit?
    params.key?(:next)
  end

  def review?
    params.key?(:review)
  end

  def view_path(step = nil)
    if @authorization_request.form.multiple_steps?
      first_step = @authorization_request_form.steps.first[:name]

      "authorization_request_forms/build/#{step || params[:id] || first_step}"
    elsif @authorization_request.form.single_page_view.present?
      @authorization_request.form.single_page_view
    else
      @authorization_request.form.uid.underscore
    end
  end

  def authorization_request_params
    params.require(authorization_request_class.model_name.singular)
  rescue ActionController::ParameterMissing
    nil
  end

  def extract_authorization_request
    @authorization_request = authorization_request_class.find(params[:id]).decorate
  end

  def authorization_request_class
    @authorization_request_form.authorization_request_class
  end

  def extract_authorization_request_form
    @authorization_request_form = AuthorizationRequestForm.find(params[:form_uid]).decorate
  end

  def review_authorization_request
    ReviewAuthorizationRequest.call(
      authorization_request: @authorization_request,
      authorization_request_params:,
      user: current_user,
    )
  end

  def layout_name
    'authorization_request'
  end
end

# rubocop:enable Metrics/ClassLength
