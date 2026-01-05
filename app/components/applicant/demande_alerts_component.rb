class Applicant::DemandeAlertsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  NOTICE_FULL_WIDTH_SINGLE_LINE_CLASSES = 'fr-notice--full-width fr-mb-4w'.freeze
  NOTICE_STANDARD_CLASSES = 'fr-mb-4w fr-px-4v'.freeze
  ALERT_CLASSES = 'fr-mb-4w'.freeze

  def initialize(authorization_request:, current_user:, authorization: nil)
    @authorization_request = authorization_request
    @current_user = current_user
    @authorization = authorization
    super()
  end

  def render?
    show_instructor_banner? ||
      show_dirty_from_v1_alert? ||
      show_update_in_progress_alert? ||
      show_old_version_alert? ||
      show_summary_before_submit?
  end

  def call
    safe_join([
      summary_before_submit_notice,
      instructor_banner_notice,
      dirty_from_v1_alert,
      update_in_progress_notice,
      old_version_notice
    ].compact)
  end

  private

  attr_reader :authorization_request, :current_user

  def summary_before_submit_notice
    return unless show_summary_before_submit?

    render DsfrComponent::NoticeComponent.new(
      title: I18n.t('authorization_request_forms.summary.title'),
      description: I18n.t('authorization_request_forms.summary.description'),
      type: 'warning',
      html_attributes: { class: NOTICE_STANDARD_CLASSES }
    )
  end

  def show_summary_before_submit?
    authorization_request.draft? && current_user_is_applicant?
  end

  def current_user_is_applicant?
    authorization_request.applicant == current_user
  end

  def instructor_banner_notice
    render Molecules::InstructorBannerNoticeComponent.new(authorization_request:)
  end

  def show_instructor_banner?
    authorization_request.changes_requested? || authorization_request.refused?
  end

  def dirty_from_v1_alert
    return unless show_dirty_from_v1_alert?

    dsfr_alert(
      type: :warning,
      title: I18n.t('authorization_requests.show.dirty_from_v1.title'),
      html_attributes: { class: ALERT_CLASSES }
    ) { I18n.t('authorization_requests.show.dirty_from_v1.description') }
  end

  def show_dirty_from_v1_alert?
    authorization_request.dirty_from_v1?
  end

  def update_in_progress_notice
    return if @authorization.blank?

    render Molecules::UpdateInProgressNoticeComponent.new(authorization: @authorization)
  end

  def show_update_in_progress_alert?
    @authorization.present? && @authorization.latest? && @authorization.request.reopening?
  end

  def show_old_version_alert?
    @authorization.present? && !@authorization.latest?
  end

  def old_version_notice
    return unless show_old_version_alert?

    render DsfrComponent::NoticeComponent.new(
      title: I18n.t('authorization_request_forms.summary.reopening_alerts.old_version.title'),
      description: old_version_message,
      type: 'warning',
      html_attributes: { class: NOTICE_FULL_WIDTH_SINGLE_LINE_CLASSES }
    )
  end

  def old_version_message
    I18n.t(
      'authorization_request_forms.summary.reopening_alerts.old_version.message',
      link: link_to(
        "Habilitation n°#{authorization_request.latest_authorization.id}",
        authorization_path(authorization_request.latest_authorization)
      )
    ).html_safe
  end
end
