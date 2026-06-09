class Instruction::Search::DashboardHabilitationsSearch < Instruction::Search::DashboardSearch
  private

  def includes_associations
    super + %i[request]
  end

  def id_search_prefix
    'H'
  end

  def default_sort
    'created_at desc'
  end
end
