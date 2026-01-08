class Habilitation::UserAlertsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  CALLOUT_CLASSES = 'fr-my-16v'.freeze

  delegate :request, to: :authorization

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
    render Molecules::UpdateInProgressNoticeComponent.new(authorization:)
  end

  def show_update_in_progress_alert?
    authorization.latest? && request.reopening?
  end

  def access_callout
    return unless show_access_callout?

    dsfr_callout(
      title: access_callout_title,
      html_attributes: { class: CALLOUT_CLASSES }
    ) do |callout|
      callout.with_action_zone do
        access_callout_button
      end
      access_callout_content
    end
  end

  def access_callout_title
    I18n.t('authorization_requests.show.access_callout.title')
  end

  def access_callout_button
    link_to(
      I18n.t('authorization_requests.show.access_callout.button'),
      request.access_link,
      class: 'fr-btn fr-btn--icon-right fr-icon-external-link-line',
      target: '_blank',
      rel: 'noopener external',
      title: "#{I18n.t('authorization_requests.show.access_callout.button')} - nouvelle fenêtre"
    )
  end

  def access_callout_content
    I18n.t('authorization_requests.show.access_callout.content', access_name: request.name)
  end

  def show_access_callout?
    request.access_link.present? && request.validated? && current_user_is_applicant?
  end

  def current_user_is_applicant?
    current_user == request.applicant
  end
end
