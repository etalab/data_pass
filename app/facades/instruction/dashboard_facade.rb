class Instruction::DashboardFacade
  attr_reader :tabs, :items, :search_engine, :partial, :unread_from_applicant_count_by_id

  Tab = Data.define(:id, :path)

  def initialize(search_object:)
    @search_object = search_object
    build_facade
  end

  private

  attr_reader :search_object

  def build_facade
    @search_engine = search_object.search_engine
    @items = search_object.paginated_results
    @tabs = build_tabs
    @partial = partial_name
    @unread_from_applicant_count_by_id = {}
  end

  def build_tabs
    [
      Tab.new('demandes', instruction_dashboard_show_path(id: 'demandes')),
      Tab.new('habilitations', instruction_dashboard_show_path(id: 'habilitations')),
    ]
  end

  def partial_name
    raise NotImplementedError, 'Subclasses must implement #partial_name'
  end

  def instruction_dashboard_show_path(id:)
    Rails.application.routes.url_helpers.instruction_dashboard_show_path(id: id)
  end
end
