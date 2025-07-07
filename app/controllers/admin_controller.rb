class AdminController < AuthenticatedUserController
  before_action :check_user_is_admin!

  layout 'admin'

  def index
    render layout: 'application'
  end

  def check_user_is_admin!
    return if true_user.admin?

    flash[:error] = {
      title: t('application.user_not_authorized.title')
    }

    redirect_to dashboard_path
  end
end
