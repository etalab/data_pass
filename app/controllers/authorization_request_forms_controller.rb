class AuthorizationRequestFormsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  before_action :extract_authorization_request_form
  before_action :extract_authorization_request, only: %i[show update]

  def new
    authorize @authorization_request_form, :new?

    @authorization_request = authorization_request_class.new(
      applicant: current_user,
      organization: current_organization,
      form_uid: @authorization_request_form.uid,
    )

    render view_path
  end

  def create
    if @authorization_request_form.multiple_steps?
      create_for_multiple_steps
    else
      create_for_single_page_form
    end
  end

  def show
    authorize @authorization_request

    if @authorization_request_form.multiple_steps?
      redirect_to_current_build_step
    else
      render view_path
    end
  end

  def update
    if final_submit?
      submit
    else
      update_model
    end
  end

  private

  def create_for_multiple_steps
    organizer = organizer_for_creation

    authorization_request = organizer.authorization_request

    step_localized = t("wicked.#{authorization_request.form.steps.first[:name]}")

    redirect_to authorization_request_form_build_path(
      form_uid: authorization_request.form_uid,
      authorization_request_id: authorization_request.id,
      id: step_localized,
    )
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

    @authorization_request = organizer.authorization_request

    if organizer.success?
      redirect_to authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
    else
      error_message(title: t('authorization_request_forms.create_for_single_page_form.error.title'), description: t('authorization_request_forms.create_for_single_page_form.error.description'))

      render view_path, status: :unprocessable_entity
    end
  end

  def organizer_for_creation
    CreateAuthorizationRequest.call(
      user: current_user,
      authorization_request_form: @authorization_request_form,
    )
  end

  def update_model
    authorize @authorization_request, :update?

    organizer = organizer_for_update

    @authorization_request = organizer.authorization_request

    if organizer.success?
      success_message(title: t('authorization_request_forms.update.success', name: @authorization_request.name))

      redirect_to authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
    else
      error_message(title: t('authorization_request_forms.update.error.title'), description: t('authorization_request_forms.update.error.description'))

      render view_path, status: :unprocessable_entity
    end
  end

  def organizer_for_update
    UpdateAuthorizationRequest.call(
      authorization_request: @authorization_request,
      authorization_request_params:,
      user: current_user,
    )
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
      success_message(title: t('authorization_request_forms.submit.success', name: @authorization_request.name))

      redirect_to dashboard_path
    else
      error_message(title: t('authorization_request_forms.submit.error.title'), description: t('authorization_request_forms.submit.error.description'))

      render view_path(:finish), status: :unprocessable_entity
    end
  end

  def final_submit?
    params[:submit].present?
  end

  def view_path(step = nil)
    if @authorization_request.form.multiple_steps?
      "authorization_request_forms/build/#{step || params[:id] || 'start'}"
    else
      @authorization_request.form.uid.underscore
    end
  end

  def authorization_request_params
    params.require(authorization_request_class.model_name.singular)
  end

  def extract_authorization_request
    @authorization_request = authorization_request_class.find(params[:id])
  end

  def authorization_request_class
    @authorization_request_form.authorization_request_class
  end

  def extract_authorization_request_form
    @authorization_request_form = AuthorizationRequestForm.find(params[:form_uid])
  end
end
