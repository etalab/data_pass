class LinkApplicantToOrganization < AddUserToOrganization
  def call
    return if member?

    @link_created = true
    super
  end

  def rollback
    return unless @link_created

    user.organizations_users.where(organization: context.organization).destroy_all
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
