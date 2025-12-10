class Dashboard::TabBlankStateComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  REASONS = %i[empty no_results].freeze

  attr_reader :tab_type, :reason

  def initialize(tab_type:, reason:)
    @tab_type = tab_type
    @reason = reason

    validate_reason!
  end

  def pictogram_path
    case reason
    when :empty
      'artwork/pictograms/document/document-add.svg'
    when :no_results
      'artwork/pictograms/digital/information.svg'
    end
  end

  def message
    case reason
    when :empty
      I18n.t("dashboard.show.empty_states.#{tab_type}.message")
    when :no_results
      I18n.t("dashboard.show.no_filter_results.#{tab_type}.message")
    end
  end

  def action_text
    case reason
    when :empty
      I18n.t('dashboard.show.empty_states.common.request_data_access')
    when :no_results
      I18n.t('dashboard.show.search.reset')
    end
  end

  def action_path
    case reason
    when :empty
      I18n.t('dashboard.show.empty_states.common.dataservices_url')
    when :no_results
      dashboard_show_path(id: tab_type)
    end
  end

  private

  def validate_reason!
    return if REASONS.include?(reason)

    raise ArgumentError, "reason must be one of #{REASONS.join(', ')}, got: #{reason}"
  end
end
