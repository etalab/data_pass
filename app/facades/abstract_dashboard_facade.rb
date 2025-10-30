class AbstractDashboardFacade
  FILTER_THRESHOLD_COUNT = 9

  attr_reader :user, :search_query, :subdomain_types, :scoped_relation

  delegate :current_organization_verified?, to: :user

  def initialize(user:, search_query:, subdomain_types:, scoped_relation:)
    @user = user
    @search_query = search_query
    @subdomain_types = subdomain_types
    @scoped_relation = scoped_relation
  end

  def show_filters?
    viewable_by_user = DemandesHabilitationsViewableByUser.new(user, scoped_relation, model_class)
    viewable_by_user.count_by_states(displayed_states) > FILTER_THRESHOLD_COUNT
  end

  def show_organization_verification_warning?
    return false if user.current_organization_verified?

    user_relationship = search_query&.dig(:user_relationship_eq)
    user_relationship.blank? || user_relationship == 'organization'
  end

  def user_relationship_options
    options = [
      [I18n.t('dashboard.show.search.user_relationship.options.applicant'), 'applicant'],
      [I18n.t('dashboard.show.search.user_relationship.options.contact'), 'contact'],
    ]
    options << [I18n.t('dashboard.show.search.user_relationship.options.organization'), 'organization'] if current_organization_verified?
    options
  end

  def data
    @data ||= { highlighted_categories: {}, categories: {}, search_engine: nil }
  end

  def highlighted_categories
    data[:highlighted_categories]
  end

  def categories
    data[:categories]
  end

  def search_engine
    data[:search_engine]
  end

  def model_class
    raise NotImplementedError, 'Subclasses must implement #model_class'
  end

  def displayed_states
    raise NotImplementedError, 'Subclasses must implement #displayed_states'
  end

  protected

  def search_builder
    @search_builder ||= DemandesHabilitationsSearchEngineBuilder.new(
      user,
      { search_query: search_query },
      subdomain_types: subdomain_types
    )
  end
end
