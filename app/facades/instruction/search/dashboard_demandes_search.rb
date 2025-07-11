class Instruction::Search::DashboardDemandesSearch < Instruction::Search::DashboardSearch
  private

  def base_relation
    base_scope = super
    base_scope = base_scope.not_validated
    base_scope = base_scope.not_archived if params.dig('search_query', 'state_eq').blank?
    base_scope = base_scope.none if search_terms_is_a_possible_id?
    base_scope
  end

  def default_sort
    'last_submitted_at desc'
  end
end
