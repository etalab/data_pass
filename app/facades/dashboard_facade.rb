class DashboardFacade
  attr_reader :tabs, :items, :search_engine, :partial

  Tab = Data.define(:id, :path, :count)

  def initialize(user = nil, search_query = nil, search_object: nil, subdomain_types: nil)
    if search_object
      # New initialization pattern
      @search_object = search_object
      build_facade
    else
      # Legacy initialization pattern for backward compatibility
      @user = user
      @search_query = search_query
      @subdomain_types = subdomain_types
    end
  end

  # New unified interface methods
  def categories
    return nil unless @search_object
    raise NotImplementedError, 'Subclasses must implement #categories'
  end

  def highlighted_categories
    return nil unless @search_object
    raise NotImplementedError, 'Subclasses must implement #highlighted_categories'
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
    return [] unless @search_object
    
    [
      Tab.new('demandes', dashboard_show_path(id: 'demandes'), demandes_count),
      Tab.new('habilitations', dashboard_show_path(id: 'habilitations'), habilitations_count),
    ]
  end

  def partial_name
    return nil unless @search_object
    raise NotImplementedError, 'Subclasses must implement #partial_name'
  end

  def demandes_count
    return nil unless @search_object
    raise NotImplementedError, 'Subclasses must implement #demandes_count'
  end

  def habilitations_count
    return nil unless @search_object
    raise NotImplementedError, 'Subclasses must implement #habilitations_count'
  end

  def dashboard_show_path(id:)
    Rails.application.routes.url_helpers.dashboard_show_path(id: id)
  end
end
