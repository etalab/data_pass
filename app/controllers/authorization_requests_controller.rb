# rubocop:disable Metrics/ClassLength
class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  before_action :extract_authorization_request_form
  before_action :extract_authorization_request, only: %i[show update]

  def new
    authorize @authorization_request_form, :new?

    @authorization_request = authorization_request_class.new(applicant: current_user, organization: current_organization)

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
      step_localized = t("wicked.#{@authorization_request_form.steps.first[:name]}")

      redirect_to authorization_request_build_path(form_uid: @authorization_request_form.uid, authorization_request_id: @authorization_request.id, id: step_localized)
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
    authorization_request = authorization_request_class.create!(
      applicant: current_user,
      organization: current_organization,
    )

    step_localized = t("wicked.#{@authorization_request_form.steps.first[:name]}")

    redirect_to authorization_request_build_path(form_uid: @authorization_request_form.uid, authorization_request_id: authorization_request.id, id: step_localized)
  end

  def create_for_single_page_form
    @authorization_request = authorization_request_class.new(
      authorization_request_create_params
    )

    if @authorization_request.save
      success_message(title: t('authorization_requests.create_for_single_page_form.success', name: @authorization_request.name))

      redirect_to authorization_request_path(form_uid: @authorization_request_form.uid, id: @authorization_request.id)
    else
      error_message(title: t('authorization_requests.create_for_single_page_form.error.title'), description: t('authorization_requests.create_for_single_page_form.error.description'))

      render view_path, status: :unprocessable_entity
    end
  end

  def update_model
    authorize @authorization_request, :update?

    if @authorization_request.update(authorization_request_update_params)
      success_message(title: t('authorization_requests.update.success', name: @authorization_request.name))

      redirect_to authorization_request_path(form_uid: @authorization_request.form.uid, id: @authorization_request.id)
    else
      error_message(title: t('authorization_requests.update.error.title'), description: t('authorization_requests.update.error.description'))

      render view_path, status: :unprocessable_entity
    end
  end

  def submit
    authorize @authorization_request, :submit?

    if @authorization_request.update(authorization_request_params) && @authorization_request.submit
      success_message(title: t('authorization_requests.submit.success', name: @authorization_request.name))

      redirect_to dashboard_path
    else
      error_message(title: t('authorization_requests.submit.error.title'), description: t('authorization_requests.submit.error.description'))

      render view_path(:finish), status: :unprocessable_entity
    end
  end

  def authorization_request_create_params
    authorization_request_params.merge(
      applicant: current_user,
      organization: current_organization,
    )
  end

  def authorization_request_update_params
    authorization_request_params
  end

  def authorization_request_params
    params.require(authorization_request_class.model_name.singular).permit(
      extract_permitted_attributes(authorization_request_class).push(
        %i[
          terms_of_service_accepted
          data_protection_officer_informed
        ]
      )
    )
  end

  def extract_permitted_attributes(authorization_request_class)
    extra_attributes = authorization_request_class.extra_attributes.map(&:to_sym).concat(
      authorization_request_class.documents.map(&:to_sym)
    )

    extra_attributes << { scopes: [] } if authorization_request_class.scopes_enabled?

    authorization_request_class.contact_types.each_with_object(extra_attributes) do |contact_type, attributes|
      attributes.concat(
        authorization_request_class.contact_attributes.map { |attribute| :"#{contact_type}_#{attribute}" }
      )
    end
  end

  def final_submit?
    params[:submit].present?
  end

  def view_path(step = nil)
    if @authorization_request.form.multiple_steps?
      "authorization_requests/build/#{step || params[:id] || 'start'}"
    else
      @authorization_request.form.uid.underscore
    end
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
# rubocop:enable Metrics/ClassLength
