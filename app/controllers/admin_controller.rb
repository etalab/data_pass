class AdminController < AuthenticatedUserController
  before_action :check_user_is_admin!
  before_action :set_paper_trail_whodunnit

  def index
    render layout: 'application'
  end

  def layout_name
    'admin'
  end

  private

  def check_user_is_admin!
    return if true_user.admin?

    flash[:error] = {
      title: t('application.user_not_authorized.title')
    }

    redirect_to dashboard_path
  end

  def set_paper_trail_whodunnit
    PaperTrail.request.whodunnit = current_user&.id&.to_s
  end
end
