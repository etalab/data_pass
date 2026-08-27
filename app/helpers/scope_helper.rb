module ScopeHelper
  ScopeDisplayGroup = Data.define(:provider, :group, :scopes) do
    def heading
      [provider, group].compact.join(' — ').presence
    end
  end

  def scope_groups_for_display(scopes)
    scopes
      .group_by { |scope| [scope.provider, scope.group] }
      .map { |(provider, group), grouped_scopes| ScopeDisplayGroup.new(provider:, group:, scopes: grouped_scopes) }
  end
end
