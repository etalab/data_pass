class AuthorizationHeaderComponent < ApplicationComponent
  attr_reader :authorization, :authorization_request, :current_user

  def initialize(authorization:, authorization_request:, current_user:)
    @authorization = authorization
    @authorization_request = authorization_request
    @current_user = current_user
  end

  def can_transfer?
    policy(authorization.try(:request) || authorization_request).transfer?
  rescue StandardError
    false
  end

  def can_reopen?
    policy(authorization.try(:request) || authorization_request).reopen?
  rescue StandardError
    false
  end

  def can_start_next_stage?
    policy(authorization_request).try(:start_next_stage?) || false
  rescue NoMethodError
    false
  end

  def can_show_instruction?
    policy([:instruction, authorization_request]).show?
  rescue StandardError
    false
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
    (authorization.revoked? || authorization.state == 'revoked') && authorization.applicant == @current_user
  end
end
