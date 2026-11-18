class LinkApplicantToOrganization < AddUserToOrganization
  def call
    return if member?

    super
  end

  protected

  def user
    context.applicant
  end

  private

  def member?
    user.organizations_users.exists?(organization_id: context.organization.id)
  end
end
