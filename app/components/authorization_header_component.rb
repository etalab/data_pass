class AuthorizationHeaderComponent < ApplicationComponent
  attr_reader :authorization, :current_user

  def initialize(authorization:, current_user:)
    @authorization = authorization
    @current_user = current_user
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
