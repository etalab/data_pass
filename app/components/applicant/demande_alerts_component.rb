class Applicant::DemandeAlertsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

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
      html_attributes: { class: 'fr-mb-4w fr-px-4v' }
    )
  end

  def show_summary_before_submit?
    authorization_request.draft? && !authorization_request.reopening? && current_user_is_applicant?
  end

  def current_user_is_applicant?
    authorization_request.applicant == current_user
  end

  def instructor_banner_notice
    return unless show_instructor_banner?

    render DsfrComponent::NoticeComponent.new(
      title: instructor_banner_title,
      description: instructor_banner_full_description,
      type: instructor_banner_type.to_s,
      html_attributes: { class: 'fr-notice--full-width fr-mb-4w' }
    )
  end

  def show_instructor_banner?
    authorization_request.changes_requested? || authorization_request.refused?
  end

  def instructor_banner_type
    return :alert if authorization_request.refused? || (authorization_request.reopening? && authorization_request.denial.present?)
    return :warning if authorization_request.changes_requested?

    nil
  end

  def instructor_banner_title
    I18n.t("#{instructor_banner_i18n_key}.title")
  end

  def instructor_banner_description
    I18n.t("#{instructor_banner_i18n_key}.description")
  end

  def instructor_banner_reason
    return authorization_request.modification_request&.reason if authorization_request.changes_requested?
    return authorization_request.denial&.reason if instructor_banner_type == :alert

    nil
  end

  def instructor_banner_full_description
    description = instructor_banner_description
    return description if instructor_banner_reason.blank?

    helpers.safe_join([description, helpers.simple_format(instructor_banner_reason)])
  end

  def instructor_banner_i18n_key
    key = if authorization_request.reopening?
            instructor_banner_type == :alert ? 'reopening_refused' : 'reopening_changes_requested'
          elsif instructor_banner_type == :alert
            'refused'
          else
            'changes_requested'
          end
    "authorization_requests.show.#{key}"
  end

  def dirty_from_v1_alert
    return unless show_dirty_from_v1_alert?

    helpers.dsfr_alert(
      type: :warning,
      title: I18n.t('authorization_requests.show.dirty_from_v1.title'),
      html_attributes: { class: 'fr-mb-4w' }
    ) { I18n.t('authorization_requests.show.dirty_from_v1.description') }
  end

  def show_dirty_from_v1_alert?
    authorization_request.dirty_from_v1?
  end

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
      html_attributes: { class: 'fr-notice--full-width fr-mb-4w' }
    )
  end

  def old_version_message
    I18n.t(
      'authorization_request_forms.summary.reopening_alerts.old_version.message',
      link: helpers.link_to(
        "Habilitation n°#{authorization_request.latest_authorization.id}",
        helpers.authorization_path(authorization_request.latest_authorization)
      )
    ).html_safe
  end

  def update_in_progress_message
    I18n.t(
      'authorization_request_forms.summary.reopening_alerts.update_in_progress.message',
      link: helpers.link_to(
        "Consulter la demande de mise à jour n°#{@authorization.request.id}",
        helpers.authorization_request_path(@authorization.request)
      )
    ).html_safe
  end
end
