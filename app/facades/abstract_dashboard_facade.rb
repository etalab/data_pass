class AbstractDashboardFacade
  include Rails.application.routes.url_helpers

  FILTER_THRESHOLD_COUNT = 9
  DEFAULT_FILTER = { user_relationship_eq: 'applicant' }.freeze

  attr_reader :user, :search_query, :subdomain_types, :scoped_relation

  delegate :current_organization_verified?, to: :user

  def initialize(user:, search_query:, subdomain_types:, scoped_relation:)
    @user = user
    @subdomain_types = subdomain_types
    @scoped_relation = scoped_relation
    @search_query = apply_default_filter(search_query)
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

  def empty?
    highlighted_categories.values.all?(&:empty?) &&
      categories.values.all?(&:empty?)
  end

  def total_count
    highlighted_categories.values.sum(&:count) +
      categories.values.sum(&:count)
  end

  def empty_with_filter?
    empty? && search_query.present?
  end

  def empty_state_component
    return nil unless empty? && !empty_with_filter?

    Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/document/document-add.svg',
      message: I18n.t("dashboard.show.empty_states.#{tab_type}.message")
    )
  end

  def empty_state_action
    return nil unless empty? && !empty_with_filter?

    {
      text: I18n.t('dashboard.show.empty_states.common.request_data_access'),
      href: I18n.t('dashboard.show.empty_states.common.dataservices_url'),
      title: "#{I18n.t('dashboard.show.empty_states.common.request_data_access')} - Ouvrir dans une nouvelle fenêtre",
      class: 'fr-link fr-link--action-high-blue-france',
      target: '_blank',
      rel: 'noopener noreferrer'
    }
  end

  def no_results_component
    return nil unless empty_with_filter?

    Dashboard::BlankStateComponent.new(
      pictogram_path: 'artwork/pictograms/digital/information.svg',
      message: I18n.t("dashboard.show.no_filter_results.#{tab_type}.message")
    )
  end

  def no_results_action
    return nil unless empty_with_filter?

    {
      text: I18n.t('dashboard.show.search.reset'),
      href: dashboard_show_path(id: tab_type),
      class: 'fr-btn fr-btn--secondary'
    }
  end

  def model_class
    raise NotImplementedError, 'Subclasses must implement #model_class'
  end

  def displayed_states
    raise NotImplementedError, 'Subclasses must implement #displayed_states'
  end

  def tab_type
    raise NotImplementedError, 'Subclasses must implement #tab_type'
  end

  protected

  def search_builder
    @search_builder ||= search_builder_class.new(
      user,
      {
        search_query: search_query,
        subdomain_types: subdomain_types
      }
    )
  end

  def search_builder_class
    "#{model_class}sSearchEngineBuilder".constantize
  end

  def apply_default_filter(search_query)
    return search_query if search_query&.dig(:user_relationship_eq).present?
    return search_query unless show_filters?

    Hash(search_query).merge(DEFAULT_FILTER)
  end
end
