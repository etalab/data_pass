class ChangeUserCurrentOrganization < AddUserToOrganization
  def current
    true
  end
end
