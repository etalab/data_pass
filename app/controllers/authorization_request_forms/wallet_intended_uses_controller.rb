class AuthorizationRequestForms::WalletIntendedUsesController < AuthorizationRequestFormsController
  STEP = :wallet_intended_uses

  def update
    authorize @authorization_request, :update?

    organizer = UpdateWalletIntendedUses.call(
      authorization_request: @authorization_request,
      authorization_request_params:,
      command: params[:wallet_command],
      user: current_user
    )

    return head(:unprocessable_content) unless organizer.success?

    redirect_to(path_after(organizer))
  rescue ActiveRecord::RecordNotUnique
    redirect_to(step_path(opened_use_id: commanded_use_id))
  end

  private

  def path_after(organizer)
    return catalog_path(organizer.catalog_use) if organizer.catalog_use

    step_path(opened_use_id: organizer.opened_use&.id, focus: organizer.focus)
  end

  def catalog_path(use)
    authorization_request_form_wallet_rulebooks_path(form_uid: @authorization_request.form_uid, authorization_request_id: @authorization_request.id, intended_use_id: use.id)
  end

  def step_path(opened_use_id:, focus: nil)
    authorization_request_form_build_path(
      form_uid: @authorization_request.form_uid,
      authorization_request_id: @authorization_request.id,
      id: I18n.t("wicked.#{STEP}"),
      ouverte: opened_use_id,
      focus:,
      anchor: 'wallet-intended-uses'
    )
  end

  def commanded_use_id
    params[:wallet_command].to_s.split(ApplyWalletIntendedUseCommand::SEPARATOR)[1]
  end

  def extract_authorization_request
    @authorization_request = authorization_request_class.find(params.expect(:authorization_request_id)).decorate
  end

  def user_not_authorized
    head :forbidden
  end
end
