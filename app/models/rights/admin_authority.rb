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

  def audit_event_name
    'user_rights_changed_by_admin'
  end

  private

  def fd_provider_slugs
    @fd_provider_slugs ||= AuthorizationDefinition.all.filter_map(&:provider_slug).uniq
  end
end
