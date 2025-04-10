class AuthorizationHeaderComponent < ApplicationComponent
  attr_reader :authorization, :current_user

  def initialize(authorization:, current_user:)
    @authorization = authorization
    @current_user = current_user
  end

  private

  def state_badge_html_class
    if authorization.revoked?
      'fr-badge--error'
    elsif authorization.state == 'obsolete'
      ''
    elsif authorization.state == 'active'
      'fr-badge--success'
    end
  end
end
