module DashboardHelper
  def dashboard_list_title(kind, items)
    own_title_keys = items.filter_map { |item| item.try(:definition)&.id }.uniq.map { |definition_id| "dashboard.show.lists.by_definition.#{definition_id}.#{kind}_title" }

    t(dashboard_list_title_candidates(own_title_keys).find { |key| I18n.exists?(key) } || "dashboard.show.lists.#{kind}_title")
  end

  private

  def dashboard_list_title_candidates(own_title_keys)
    renamed_keys = own_title_keys.select { |key| I18n.exists?(key) }
    return [] unless renamed_keys.one?

    own_title_keys.one? ? renamed_keys : [renamed_keys.first.sub(/_title\z/, '_mixed_title')]
  end
end
