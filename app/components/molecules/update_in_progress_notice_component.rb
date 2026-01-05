class Molecules::UpdateInProgressNoticeComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  NOTICE_CLASSES = 'fr-notice--full-width fr-mb-4w'.freeze

  def initialize(authorization:)
    @authorization = authorization
    super()
  end

  def render?
    authorization.latest? && authorization.request.reopening?
  end

  def call
    render DsfrComponent::NoticeComponent.new(
      title:,
      description:,
      type: 'info',
      html_attributes: { class: NOTICE_CLASSES }
    )
  end

  private

  attr_reader :authorization

  delegate :request, to: :authorization

  def title
    I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title')
  end

  def description
    I18n.t(
      'authorization_request_forms.summary.reopening_alerts.update_in_progress.message',
      link: request_link
    ).html_safe
  end

  def request_link
    link_to(
      I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.link_text', id: request.id),
      authorization_request_path(request)
    )
  end
end
