class InstructionController < AuthenticatedUserController
  before_action :check_user_is_reporter!

  def check_user_is_reporter!
    return if current_user.reporter?

    flash[:error] = {
      title: t('application.user_not_authorized.title')
    }

    redirect_to dashboard_path
  end
end
