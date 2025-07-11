class Instruction::DashboardFacade
  attr_reader :tabs, :items, :search_engine, :partial

  Tab = Data.define(:id, :path, :count)

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
  end

  def build_tabs
    [
      Tab.new('demandes', instruction_dashboard_show_path(id: 'demandes'), demandes_count),
      Tab.new('habilitations', instruction_dashboard_show_path(id: 'habilitations'), habilitations_count),
    ]
  end

  def partial_name
    raise NotImplementedError, 'Subclasses must implement #partial_name'
  end

  def demandes_count
    raise NotImplementedError, 'Subclasses must implement #demandes_count'
  end

  def habilitations_count
    raise NotImplementedError, 'Subclasses must implement #habilitations_count'
  end

  def instruction_dashboard_show_path(id:)
    Rails.application.routes.url_helpers.instruction_dashboard_show_path(id: id)
  end
end
