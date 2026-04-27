class Instruction::UserRightsView
  def initialize(manager:, user:)
    @manager = manager
    @user = user
  end

  def modifiable
    covered_rights.select { |right| allowed_role_type?(right[:role_type]) }
  end

  def readonly
    covered_rights.reject { |right| allowed_role_type?(right[:role_type]) }
  end

  def all_visible
    covered_rights
  end

  def grouped_visible
    entries = covered_rights.group_by { |right| right[:scope] }.map do |scope_string, rights|
      {
        scope: scope_string,
        label: Instruction::Scope.new(scope_string).label,
        role_types: rights.map { |right| right[:role_type] }
      }
    end
    entries.sort_by { |entry| entry[:label] }
  end

  private

  def covered_rights
    @covered_rights ||= @user.roles.filter_map do |role_string|
      next unless @manager.manages_role?(role_string)

      parsed = ParsedRole.parse(role_string)
      { scope: "#{parsed.provider_slug}:#{parsed.definition_id}", role_type: parsed.role }
    end
  end

  def allowed_role_type?(role_type)
    Instruction::ManagerScopeOptions::ALLOWED_ROLE_TYPES.include?(role_type)
  end
end
