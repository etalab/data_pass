class Atoms::UnderDevelopmentAlertComponent < ApplicationComponent
  CONTACT_EMAIL = 'datapass@api.gouv.fr'.freeze

  def initialize(wip_action:)
    @wip_action = wip_action
  end

  private

  attr_reader :wip_action

  def title
    I18n.t('atoms.under_development_alert_component.title')
  end

  def message_html
    I18n.t(
      'atoms.under_development_alert_component.message_html',
      wip_action:,
      contact_link:
    ).html_safe
  end

  def contact_link
    link_to(CONTACT_EMAIL, "mailto:#{CONTACT_EMAIL}", class: 'fr-link')
  end
end
