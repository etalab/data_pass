class Admin::TransferAuthorizationRequestsController < AdminController
  def new; end

  def create
    organizer = transfer_authorization_request

    if organizer.success?
      handle_successful_transfer(organizer)
    else
      handle_failed_transfer(organizer)
    end
  end

  private

  def transfer_params
    params.permit(:authorization_request_id, :new_organization_siret, :new_applicant_email)
  end

  def transfer_authorization_request
    Admin::TransferAuthorizationRequest.call(
      **transfer_params.to_h.symbolize_keys,
      user: true_user
    )
  end

  def handle_successful_transfer(organizer)
    success_message(
      title: I18n.t('admin.transfer_authorization_requests.create.success.title'),
      description: I18n.t(
        'admin.transfer_authorization_requests.create.success.description',
        authorization_request_id: organizer.authorization_request.id,
        siret: organizer.new_organization.siret
      )
    )

    redirect_to admin_path
  end

  def handle_failed_transfer(organizer)
    error_message(
      title: I18n.t('admin.transfer_authorization_requests.errors.title'),
      description: error_description(organizer)
    )

    render :new, status: :unprocessable_content
  end

  def error_description(organizer)
    if organizer.error == :invalid_new_organization
      organizer.authorization_request.errors.full_messages.join(', ')
    else
      error_translation(organizer.error)
    end
  end

  def error_translation(error_key)
    I18n.t(
      "admin.transfer_authorization_requests.errors.#{error_key}",
      authorization_request_id: transfer_params[:authorization_request_id],
      siret: transfer_params[:new_organization_siret],
      email: transfer_params[:new_applicant_email]
    )
  end
end
