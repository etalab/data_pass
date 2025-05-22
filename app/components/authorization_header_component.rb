class AuthorizationHeaderComponent < ApplicationComponent
  attr_reader :authorization, :current_user

  def initialize(authorization:, current_user:)
    @authorization = authorization
    @current_user = current_user
  end

  def translated_state
    I18n.t(authorization.state, scope: 'authorization.states', default: authorization.state)
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
      'fr-text-mention-grey authorization-header__text--inactive'
    else
      'fr-text-inverted--blue-france'
    end
  end

  def button_class(base_classes)
    return base_classes unless %w[revoked obsolete].include?(authorization.state)

    base_classes.reject { |classe| classe == 'fr-btn-secondary' }
  end

  private

  def state_badge_html_class
    case authorization.state
    when 'revoked' then 'fr-badge--error'
    when 'active' then 'fr-badge--success'
    else ''
    end
  end
end
