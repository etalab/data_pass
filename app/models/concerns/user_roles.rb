module UserRoles
  extend ActiveSupport::Concern

  def roles=(value)
    super
    @role_sets = nil
  end

  def roles_for(kind)
    @role_sets ||= {}
    @role_sets[kind] ||= RoleSet.new(roles, kind)
  end

  def instructor?(definition_id = nil)
    roles_for(:instructor).covers?(definition_id)
  end

  def manager?(definition_id = nil)
    roles_for(:manager).covers?(definition_id)
  end

  def reporter?(definition_id = nil)
    return true if admin?

    roles_for(:reporter).covers?(definition_id)
  end

  def fd_reporter?(provider_slug)
    return true if admin?

    roles_for(:reporter).provider_slugs.include?(provider_slug)
  end

  def developer?
    roles_for(:developer).any?
  end

  def definition_ids_for(kind)
    roles_for(kind).definition_ids
  end

  def managed_fd_slugs
    roles.filter_map { |role_string|
      parsed = ParsedRole.parse(role_string)
      parsed.provider_slug if parsed.fd_level? && parsed.role == 'manager'
    }.uniq
  end

  def manages_role?(role_string)
    parsed = ParsedRole.parse(role_string)
    return false if parsed.admin? || parsed.role.nil?

    if parsed.fd_level?
      managed_fd_slugs.include?(parsed.provider_slug)
    else
      definition_ids_for(:manager).include?(parsed.definition_id)
    end
  end

  def managed_by?(other_user)
    roles.any? { |role| other_user.manages_role?(role) }
  end

  def authorization_request_types_for(kind)
    roles_for(kind).authorization_request_types
  end

  def grant_role(kind, definition_id)
    fd = ParsedRole.resolve_provider_slug(definition_id)
    raise ParsedRole::UnknownDefinitionError, "Unknown definition: #{definition_id}" unless fd

    roles << "#{fd}:#{definition_id}:#{kind}"
    roles.uniq!
    @role_sets = nil
  end

  def grant_fd_role(kind, provider_slug)
    roles << "#{provider_slug}:*:#{kind}"
    roles.uniq!
    @role_sets = nil
  end

  def grant_admin_role
    roles << 'admin'
    roles.uniq!
    @role_sets = nil
  end

  def revoke_all_roles
    self.roles = []
    @role_sets = nil
  end

  def admin?
    roles.include?('admin') ||
      bug_bounty_users_within_staging_env?
  end

  def bug_bounty_users_within_staging_env?
    Rails.env.staging? &&
      /-ywhadmin@yopmail.com$/.match?(email)
  end

  def authorization_definition_roles_as(kind)
    roles_for(kind).authorization_definitions
  end
end
