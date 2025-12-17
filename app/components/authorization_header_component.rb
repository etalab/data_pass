class AuthorizationHeaderComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  attr_reader :authorization, :current_user

  delegate :translated_state, to: :decorated_authorization

  def initialize(authorization:, current_user:)
    @authorization = authorization
    @current_user = current_user
  end

  def decorated_authorization
    @decorated_authorization ||= authorization.decorate
  end

  def header_background_class
    if %w[revoked obsolete].include?(authorization.state)
      'fr-background-alt--grey'
    else
      'fr-background-action-high--blue-france'
    end
  end

  def header_text_class
    if %w[revoked obsolete].include?(authorization.state)
      'fr-text-mention-grey'
    else
      'fr-text-inverted--blue-france'
    end
  end

  def show_old_version_alert?
    !authorization.latest?
  end

  def old_version_message
    latest = authorization.request.latest_authorization
    I18n.t(
      'components.authorization_header_component.old_version',
      link: helpers.link_to(
        I18n.t('components.authorization_header_component.old_version_link', id: latest.id),
        helpers.authorization_path(latest)
      )
    ).html_safe
  end
end
