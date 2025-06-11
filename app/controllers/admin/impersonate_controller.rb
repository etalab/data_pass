class Admin::ImpersonateController < AdminController
  def new
    @impersonation = Impersonation.new
  end

  def create
    result = start_impersonation

    if result.success?
      handle_successful_impersonation(result)
    else
      handle_failed_impersonation(result)
    end
  end

  def destroy
    AdminEvent.create!(
      admin: true_user,
      name: 'impersonate_stop',
      entity: current_user
    )

    stop_impersonating_user

    success_message(
      title: I18n.t('admin.impersonate.stop.title'),
      description: I18n.t('admin.impersonate.stop.description', email: current_user.email)
    )
    redirect_to admin_path
  end

  private

  def impersonation_params
    params.expect(impersonation: %i[email reason])
  end

  def start_impersonation
    StartImpersonation.call(
      user_identifier: impersonation_params[:email],
      admin: current_user,
      reason: impersonation_params[:reason],
      session: session
    )
  end

  def handle_successful_impersonation(result)
    success_message(
      title: I18n.t('admin.impersonate.success.title'),
      description: I18n.t('admin.impersonate.success.description', email: result.target_user.email)
    )
    redirect_to dashboard_path
  end

  def handle_failed_impersonation(result)
    error_message(
      title: I18n.t('admin.impersonate.errors.title'),
      description: I18n.t("admin.impersonate.errors.#{result.error}")
    )
    redirect_to new_admin_impersonate_path
  end
end
