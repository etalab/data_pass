module ScopeHelper
  ScopeDisplayGroup = Data.define(:provider_label, :group, :scopes) do
    def heading
      [provider_label, group].compact.join(' — ').presence
    end
  end

  def scope_groups_for_display(scopes)
    scopes
      .group_by { |scope| [scope.provider_label, scope.group] }
      .map { |(provider_label, group), grouped_scopes| ScopeDisplayGroup.new(provider_label:, group:, scopes: grouped_scopes) }
  end
end
