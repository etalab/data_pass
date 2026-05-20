class Rights::AdminAuthority < Rights::Authority
  ALLOWED_ROLE_TYPES = %w[reporter instructor manager developer].freeze

  def allowed_role_types
    ALLOWED_ROLE_TYPES
  end

  def managed_definitions
    AuthorizationDefinition.all
  end

  def fd_manager_for?(_provider_slug)
    true
  end

  def can_manage_role?(role_string)
    parsed = ParsedRole.parse(role_string)
    return false if parsed.admin? || parsed.role.nil?

    allowed_role_types.include?(parsed.role)
  end

  def covers_role?(role_string)
    !ParsedRole.parse(role_string).role.nil?
  end

  def audit_event_name
    'user_rights_changed_by_admin'
  end

  private

  def fd_provider_slugs
    @fd_provider_slugs ||= AuthorizationDefinition.all.filter_map(&:provider_slug).uniq
  end
end
