class Instruction::Search::DashboardHabilitationsSearch < Instruction::Search::DashboardSearch
  private

  def base_relation
    base_scope = super
    base_scope = base_scope.none if search_terms_is_a_possible_id?
    base_scope
  end

  def default_sort
    'created_at desc'
  end
end
