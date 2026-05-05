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

  def audit_event_name
    'user_rights_changed_by_manager'
  end

  private

  def fd_provider_slugs
    user.managed_fd_slugs
  end
end
