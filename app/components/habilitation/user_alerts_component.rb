class Habilitation::UserAlertsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  def initialize(authorization:, current_user:)
    @authorization = authorization
    @current_user = current_user
    super()
  end

  def render?
    show_update_in_progress_alert? || show_access_callout?
  end

  def call
    safe_join([
      update_in_progress_notice,
      access_callout
    ].compact)
  end

  private

  attr_reader :authorization, :current_user

  def update_in_progress_notice
    return unless show_update_in_progress_alert?

    render DsfrComponent::NoticeComponent.new(
      title: I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title'),
      description: update_in_progress_message,
      type: 'info',
      html_attributes: { class: 'fr-notice--full-width fr-mb-4w' }
    )
  end

  def show_update_in_progress_alert?
    authorization.latest? && authorization.request.reopening?
  end

  def update_in_progress_message
    I18n.t(
      'authorization_request_forms.summary.reopening_alerts.update_in_progress.message',
      link: helpers.link_to(
        "Consulter la demande de mise à jour n°#{authorization.request.id}",
        helpers.authorization_request_path(authorization.request)
      )
    ).html_safe
  end

  def access_callout
    return unless show_access_callout?

    helpers.dsfr_callout(
      title: I18n.t('authorization_requests.show.access_callout.title'),
      html_attributes: { class: 'fr-my-16v' }
    ) do |callout|
      callout.with_action_zone do
        helpers.link_to(
          I18n.t('authorization_requests.show.access_callout.button'),
          authorization.request.access_link,
          class: 'fr-btn fr-btn--icon-right fr-icon-external-link-line',
          target: '_blank',
          rel: 'noopener'
        )
      end
      I18n.t('authorization_requests.show.access_callout.content', access_name: authorization.request.name)
    end
  end

  def show_access_callout?
    authorization.request.access_link.present? &&
      authorization.request.validated? &&
      current_user == authorization.request.applicant
  end
end
