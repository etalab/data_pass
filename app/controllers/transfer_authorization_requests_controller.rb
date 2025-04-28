class TransferAuthorizationRequestsController < AuthenticatedUserController
  before_action :extract_authorization_request
  before_action :authorize_authorization_request_transfer
  before_action :extract_to_new_applicant

  attr_reader :to_new_applicant

  def new
    @authorization_request_transfer = AuthorizationRequestTransfer.new

    render "new_#{to_new_applicant}"
  end

  def create
    organizer = TransferAuthorizationRequestToNewApplicant.call(transfer_authorization_request_params)

    if organizer.success?
      success_message(title: t(".#{to_new_applicant}.success", name: @authorization_request.name, new_applicant_email: organizer.new_applicant_email))

      redirect_to authorization_request_path(@authorization_request),
        status: :see_other
    else
      @authorization_request_transfer = AuthorizationRequestTransfer.new

      affect_local_error(organizer)

      render "new_#{to_new_applicant}", status: :unprocessable_entity
    end
  end

  private

  def extract_to_new_applicant
    @to_new_applicant = @authorization_request.applicant == current_user ? :to_another : :to_me
  end

  def transfer_authorization_request_params
    {
      new_applicant_email:,
      authorization_request: @authorization_request,
      user: current_user,
    }
  end

  def new_applicant_email
    if to_new_applicant == :to_another
      params.dig(:authorization_request_transfer, :to)
    else
      current_user.email
    end
  end

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def authorize_authorization_request_transfer
    authorize @authorization_request, :transfer?
  end

  def affect_local_error(organizer)
    @error = t(
      ".#{to_new_applicant}.error.#{organizer.error}",
      organization_name: @authorization_request.organization.name,
      organization_siret: @authorization_request.organization.siret,
    )
  end
end
