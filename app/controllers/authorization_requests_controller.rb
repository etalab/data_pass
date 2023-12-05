class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  before_action :extract_authorization_request_form
  before_action :extract_authorization_request, only: %i[show update]

  def new
    @authorization_request = authorization_request_class.new(applicant: current_user, organization: current_user.organizations.first)

    render @authorization_request_form.view_path
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @authorization_request = authorization_request_class.new(
      authorization_request_params.merge(
        applicant: current_user,
      )
    )

    if @authorization_request.save
      success_message(title: t('.success', intitule: @authorization_request.intitule))

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
      authorize @authorization_request

      success_message(title: t('.success', intitule: @authorization_request.intitule))

      redirect_to authorization_request_path(form_uid: @authorization_request.form_model.uid, id: @authorization_request.id)
    else
      error_message_for(@authorization_request, title: t('.error'))

      render @authorization_request_form.view_path, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def submit
    authorize @authorization_request

    if @authorization_request.update(authorization_request_params) && @authorization_request.submit
      success_message(title: t('.success', intitule: @authorization_request.intitule))

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
          organization_id
        ]
      )
    )
  end

  def extract_permitted_attributes(authorization_request_class)
    extra_attributes = authorization_request_class.extra_attributes.map(&:to_sym)

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
end
