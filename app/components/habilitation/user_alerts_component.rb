class Habilitation::UserAlertsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  def initialize(authorization:, current_user:)
    @authorization = authorization
    @current_user = current_user
    super()
  end

  def render?
    show_contact_mention_alert? ||
      show_update_in_progress_alert? ||
      show_access_callout?
  end

  def show_contact_mention_alert?
    decorated_authorization.only_in_contacts?(current_user)
  end

  def show_update_in_progress_alert?
    authorization.latest? &&
      authorization.request.reopening?
  end

  def show_access_callout?
    authorization.request.access_link.present? &&
      authorization.request.validated? &&
      current_user == authorization.request.applicant
  end

  def contact_mention_text
    I18n.t(
      'demandes_habilitations.current_user_mentions_alert.text',
      contact_types: decorated_authorization.humanized_contact_types_for(current_user).to_sentence
    )
  end

  def update_in_progress_title
    I18n.t('authorization_request_forms.summary.reopening_alerts.update_in_progress.title')
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

  def access_callout_title
    I18n.t('authorization_requests.show.access_callout.title')
  end

  def access_callout_content
    I18n.t('authorization_requests.show.access_callout.content', access_name: authorization.request.name)
  end

  def access_callout_button_text
    I18n.t('authorization_requests.show.access_callout.button')
  end

  def access_callout_link
    authorization.request.access_link
  end

  private

  attr_reader :authorization, :current_user

  def decorated_authorization
    @decorated_authorization ||= authorization.decorate
  end
end
