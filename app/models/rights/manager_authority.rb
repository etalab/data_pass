class Rights::ManagerAuthority < Rights::Authority
  ALLOWED_ROLE_TYPES = %w[reporter instructor manager].freeze

  def allowed_role_types
    ALLOWED_ROLE_TYPES
  end

  def managed_definitions
    @managed_definitions ||= user.authorization_definition_roles_as(:manager)
  end

  def fd_manager_for?(provider_slug)
    fd_provider_slugs.include?(provider_slug)
  end

  def can_manage_role?(role_string)
    return false unless covers_role?(role_string)

    allowed_role_types.include?(ParsedRole.parse(role_string).role)
  end

  def covers_role?(role_string)
    parsed = ParsedRole.parse(role_string)
    return false if parsed.admin? || parsed.role.nil?

    user.manages_role?(role_string)
  end

  def audit_event_name
    'user_rights_changed_by_manager'
  end

  private

  def fd_provider_slugs
    user.managed_fd_slugs
  end
end
