class Instruction::Search::DashboardDemandesSearch < Instruction::Search::DashboardSearch
  private

  def base_relation
    base_scope = super
    base_scope = base_scope.not_validated
    base_scope = base_scope.not_archived if state_filter_blank?
    base_scope = base_scope.none if search_terms_is_a_possible_id?
    base_scope
  end

  def default_sort
    'last_submitted_at desc'
  end

  def state_filter_blank?
    state_eq = params.dig('search_query', 'state_eq')
    state_in = params.dig('search_query', 'state_in')

    state_eq.blank? && (state_in.blank? || state_in.reject(&:blank?).empty?)
  end
end
