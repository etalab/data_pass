class Dashboard::NoFilterResultsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  attr_reader :tab_type, :pictogram_path

  def initialize(tab_type:)
    @tab_type = tab_type
    @pictogram_path = 'artwork/pictograms/digital/information.svg'
  end

  def message
    I18n.t("dashboard.show.no_filter_results.#{tab_type}.message")
  end

  def reset_path
    dashboard_show_path(id: tab_type)
  end

  def reset_button_text
    I18n.t('dashboard.show.search.reset')
  end
end
