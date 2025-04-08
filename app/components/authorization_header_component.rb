class AuthorizationHeaderComponent < ApplicationComponent
  attr_reader :authorization, :authorization_request

  def initialize(authorization:, authorization_request:)
    @authorization = authorization
    @authorization_request = authorization_request
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

  def show_contact_support_button?
    authorization.revoked? || authorization.state == 'revoked'
  end
end
