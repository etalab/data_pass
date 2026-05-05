module UserRightsPathsHelper
  def user_rights_namespace
    controller.controller_path.start_with?('admin/') ? :admin : :instruction
  end

  def user_rights_index_path
    send(:"#{user_rights_namespace}_user_rights_path")
  end

  def new_user_right_path
    send(:"new_#{user_rights_namespace}_user_right_path")
  end

  def edit_user_right_path(user)
    send(:"edit_#{user_rights_namespace}_user_right_path", user)
  end

  def user_right_path(user)
    send(:"#{user_rights_namespace}_user_right_path", user)
  end

  def confirm_destroy_user_right_path(user)
    send(:"confirm_destroy_#{user_rights_namespace}_user_right_path", user)
  end
end
