class Instruction::ManagerScopeOptions
  ALLOWED_ROLE_TYPES = %w[reporter instructor manager].freeze

  def initialize(manager)
    @manager = manager
  end

  def allowed_role_types
    ALLOWED_ROLE_TYPES
  end

  def authorized_scopes
    @authorized_scopes ||= definition_scopes + fd_scopes
  end

  def managed_definitions
    @managed_definitions ||= @manager.authorization_definition_roles_as(:manager)
  end

  def fd_manager_for?(provider_slug)
    managed_fd_slugs.include?(provider_slug)
  end

  private

  def managed_fd_slugs
    @manager.managed_fd_slugs
  end

  def definition_scopes
    managed_definitions.map { |ad| "#{ad.provider_slug}:#{ad.id}" }
  end

  def fd_scopes
    managed_fd_slugs.map { |slug| "#{slug}:*" }
  end
end
