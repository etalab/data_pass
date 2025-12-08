class Dashboard::NoResultsComponent < ApplicationComponent
  def message
    I18n.t('dashboard.show.no_results.message')
  end

  def suggestion
    I18n.t('dashboard.show.no_results.suggestion')
  end
end
