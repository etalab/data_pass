class Admin::UpdateUserRolesAttribute < ApplicationInteractor
  def call
    remove_obsolete_roles
    add_missing_roles
    user.user_roles.reset
  end

  def remove_obsolete_roles
    user.user_roles.reload.reject { |ur| desired_attrs.any? { |d| role_matches?(ur, d) } }.each(&:destroy!)
  end

  def add_missing_roles
    desired_attrs.reject { |d| user.user_roles.reload.any? { |ur| role_matches?(ur, d) } }
      .each { |attrs| user.user_roles.create!(attrs) }
  end

  private

  def desired_attrs
    @desired_attrs ||= valid_role_attrs
  end

  def valid_role_attrs
    context.roles.select { |r| ParsedRole.valid?(r) }.filter_map { |r| build_attrs(r) }
  end

  def build_attrs(role_string)
    parsed = ParsedRole.parse(role_string)
    return { role: 'admin' } if parsed.admin?

    dp = DataProvider.find_by(slug: parsed.provider_slug)

    {
      role: parsed.role,
      data_provider: dp,
      data_provider_slug: parsed.provider_slug,
      authorization_definition_id: parsed.fd_level? ? nil : parsed.definition_id,
    }
  end

  def role_matches?(user_role, attrs)
    user_role.role == attrs[:role] &&
      user_role.data_provider_slug == attrs[:data_provider_slug] &&
      user_role.authorization_definition_id == attrs[:authorization_definition_id]
  end

  def user
    context.user
  end
end
