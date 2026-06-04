class Instruction::Search::DashboardDemandesSearch < Instruction::Search::DashboardSearch
  private

  def base_relation
    base_scope = super
    base_scope = base_scope.not_validated
    base_scope = base_scope.not_archived if state_filter_blank?
    base_scope
  end

  def id_search_prefix
    'D'
  end

  def default_sort
    'last_submitted_at desc'
  end

  def state_filter_blank?
    state_in = params.dig('search_query', 'state_in')

    state_in.blank? || state_in.compact_blank.empty?
  end
end
