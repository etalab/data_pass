class Applicant::DemandeAlertsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  def initialize(authorization_request:, current_user:, authorization: nil)
    @authorization_request = authorization_request
    @current_user = current_user
    @authorization = authorization
    super()
  end

  def render?
    show_contact_mention_alert? ||
      show_instructor_banner? ||
      show_dirty_from_v1_alert? ||
      show_update_in_progress_alert? ||
      show_old_version_alert? ||
      show_summary_before_submit?
  end

  def show_contact_mention_alert?
    decorated_authorization_request.only_in_contacts?(current_user)
  end

  def contact_mention_text
    I18n.t(
      'demandes_habilitations.current_user_mentions_alert.text',
      contact_types: decorated_authorization_request.humanized_contact_types_for(current_user).to_sentence
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

  def show_dirty_from_v1_alert?
    authorization_request.dirty_from_v1?
  end

  def show_update_in_progress_alert?
    @authorization.present? && @authorization.latest? && @authorization.request.reopening?
  end

  def show_old_version_alert?
    @authorization.present? && !@authorization.latest?
  end

  def old_version_title
    I18n.t('authorization_request_forms.summary.reopening_alerts.old_version.title')
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

  def show_summary_before_submit?
    authorization_request.draft? && !authorization_request.reopening?
  end

  def update_in_progress_title
    I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title')
  end

  def update_in_progress_message
    I18n.t(
      'authorization_request_forms.summary.reopening_alerts.update_in_progress.message',
      link: helpers.link_to(
        "Demande de mise à jour n°#{@authorization.request.id}",
        helpers.authorization_request_path(@authorization.request)
      )
    ).html_safe
  end

  private

  attr_reader :authorization_request, :current_user

  def decorated_authorization_request
    @decorated_authorization_request ||= authorization_request.decorate
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
end
