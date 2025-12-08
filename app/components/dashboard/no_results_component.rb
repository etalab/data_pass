class Dashboard::NoResultsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  attr_reader :tab_type

  def initialize(tab_type:)
    @tab_type = tab_type
  end

  def message
    I18n.t("dashboard.show.no_results.#{tab_type}.message")
  end

  def reset_path
    dashboard_show_path(id: tab_type)
  end

  def reset_button_text
    I18n.t('dashboard.show.search.reset')
  end
end
