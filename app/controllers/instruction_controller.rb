class InstructionController < AuthenticatedUserController
  before_action :check_user_is_instructor!

  def check_user_is_instructor!
    return if current_user.instructor?

    flash[:error] = {
      title: t('application.user_not_authorized.title')
    }

    redirect_to root_path
  end
end
