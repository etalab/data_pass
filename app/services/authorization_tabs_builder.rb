class AuthorizationTabsBuilder
  include Rails.application.routes.url_helpers

  def initialize(authorization, policy)
    @authorization = authorization
    @policy = policy
  end

  def build
    default_tabs.merge(conditional_tabs)
  end

  private

  attr_reader :authorization, :policy

  def authorization_request
    authorization.request
  end

  def authorizations_path
    authorization_related_authorizations_path(authorization)
  end

  def conditional_tabs
    {}.tap do |tabs|
      tabs[:authorization_request_events] = events_path if show_events_tab?
      tabs[:messages] = messages_path if show_messages_tab?
      tabs[:authorizations] = authorizations_path if show_authorizations_tab?
      tabs[:france_connected_authorizations] = france_connected_path if show_france_connected_tab?
    end
  end

  def default_tabs
    { authorization: summary_path }
  end

  def events_path
    authorization_events_path(authorization)
  end

  def france_connected_path
    authorization_france_connected_authorizations_path(authorization)
  end

  def messages_path
    authorization_messages_path(authorization)
  end

  def show_authorizations_tab?
    policy.authorizations?
  end

  def show_events_tab?
    policy.events?
  end

  def show_france_connected_tab?
    authorization_request.definition.france_connect? &&
      authorization_request.france_connected_authorizations.exists?
  end

  def show_messages_tab?
    policy.messages?
  end

  def summary_path
    authorization_path(authorization)
  end
end
