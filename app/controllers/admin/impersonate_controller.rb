class Admin::ImpersonateController < AdminController
  def new
    @impersonation = Impersonation.new
  end

  def create
    organizer = start_impersonation

    if organizer.success?
      handle_successful_impersonation(organizer)
    else
      handle_failed_impersonation(organizer)
    end
  end

  def destroy
    Admin::StopImpersonation.call(
      admin: true_user,
      impersonation: current_impersonation,
    )

    stop_impersonating_user
    cookies.delete(:impersonation_id)

    success_message(
      title: I18n.t('admin.impersonate.stop.title'),
      description: I18n.t('admin.impersonate.stop.description', email: true_user.email)
    )

    redirect_to admin_path
  end

  private

  def impersonation_params
    params.expect(impersonation: %i[email reason])
  end

  def start_impersonation
    Admin::StartImpersonation.call(
      user_email: impersonation_params[:email],
      admin: current_user,
      impersonation_params: impersonation_params.slice(:reason),
    )
  end

  def handle_successful_impersonation(organizer)
    impersonate_user(organizer.target_user)

    cookies[:impersonation_id] = { value: organizer.impersonation.id, expires: Impersonation::MAX_TIME_TO_LIVE.from_now }

    success_message(
      title: I18n.t('admin.impersonate.success.title'),
      description: I18n.t('admin.impersonate.success.description', email: organizer.target_user.email)
    )

    redirect_to dashboard_path
  end

  def handle_failed_impersonation(organizer)
    @impersonation = organizer.impersonation || Impersonation.new

    description = if organizer.error == :model_error
                    organizer.impersonation.errors.full_messages.join(', ')
                  else
                    I18n.t("admin.impersonate.errors.#{organizer.error}")
                  end

    error_message(
      title: I18n.t('admin.impersonate.errors.title'),
      description:
    )

    render :new, status: :unprocessable_entity
  end
end
