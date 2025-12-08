class Dashboard::EmptyListComponent < ApplicationComponent
  attr_reader :tab_type, :pictogram_path

  def initialize(tab_type:)
    @tab_type = tab_type
    @pictogram_path = 'artwork/pictograms/document/document-add.svg'
  end

  def message
    I18n.t("dashboard.show.empty_states.#{tab_type}.message")
  end

  def cta_text
    I18n.t('dashboard.show.empty_states.common.cta_text')
  end

  def dataservices_url
    I18n.t('dashboard.show.empty_states.common.dataservices_url')
  end
end
