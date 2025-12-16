class Instructor::DemandeAlertsComponent < ApplicationComponent
  include Rails.application.routes.url_helpers

  def initialize(authorization_request:)
    @authorization_request = authorization_request
    super()
  end

  def render?
    authorization_request.reopening?
  end

  def reopening_callout_text
    I18n.t('authorization_requests.shared.reopening_callout.text.instructor')
  end

  def authorization_link_text
    I18n.t(
      'authorization_requests.shared.reopening_callout.link.text',
      authorization_created_at: authorization_request.latest_authorization.created_at.to_date
    )
  end

  def authorization_path
    latest_authorization_path(authorization_request)
  end

  private

  attr_reader :authorization_request

  def latest_authorization_path(auth_request)
    authorization_path_by_definition(auth_request.latest_authorization)
  end

  def authorization_path_by_definition(authorization)
    helpers.authorization_path(authorization.definition.id, authorization)
  end
end
