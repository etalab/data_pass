class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  before_action :extract_authorization_request_form
  before_action :extract_authorization_request, only: %i[show update]
  before_action :check_authorization_request_unicity!, only: %i[new]

  def new
    @authorization_request = authorization_request_class.new(applicant: current_user, organization: current_organization)
    render @authorization_request_form.view_path
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @authorization_request = authorization_request_class.new(
      authorization_request_params.merge(
        applicant: current_user,
        organization: current_organization,
      )
    )

    if @authorization_request.save
      success_message(title: t('.success', id: @authorization_request.id))

      redirect_to authorization_request_path(form_uid: @authorization_request.form_model.uid, id: @authorization_request.id)
    else
      error_message_for(@authorization_request, title: t('.error'))

      render @authorization_request_form.view_path, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def show
    authorize @authorization_request

    render @authorization_request_form.view_path
  end

  # rubocop:disable Metrics/AbcSize
  def update
    if params[:submit].present?
      submit
    elsif @authorization_request.update(authorization_request_params)
      authorize @authorization_request, :update?

      success_message(title: t('.success', title: @authorization_request.title))

      redirect_to authorization_request_path(form_uid: @authorization_request.form_model.uid, id: @authorization_request.id)
    else
      error_message_for(@authorization_request, title: t('.error'))

      render @authorization_request_form.view_path, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def submit
    authorize @authorization_request, :submit?

    if @authorization_request.update(authorization_request_params) && @authorization_request.submit
      success_message(title: t('.success', title: @authorization_request.title))

      redirect_to authorization_request_path(form_uid: @authorization_request.form_model.uid, id: @authorization_request.id)
    else
      error_message_for(@authorization_request, title: t('.error'))

      render @authorization_request_form.view_path, status: :unprocessable_entity
    end
  end

  private

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

  def extract_authorization_request
    @authorization_request = authorization_request_class.find(params[:id])
  end

  def authorization_request_class
    @authorization_request_form.authorization_request_class
  end

  def extract_authorization_request_form
    @authorization_request_form = AuthorizationRequestForm.find(params[:form_uid])
  end

  def another_of_this_type_already_exists?
    current_organization.authorization_requests.where(type: authorization_request_class.to_s).any?
  end

  def check_authorization_request_unicity!
    return unless @authorization_request_form.unique && another_of_this_type_already_exists?

    warning_message(title: t('authorization_requests.new.unicity_error'))

    redirect_to root_path
  end
end
