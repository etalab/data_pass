class AuthorizationRequestTabsBuilder
  include Rails.application.routes.url_helpers

  def initialize(authorization_request, policy)
    @authorization_request = authorization_request
    @policy = policy
  end

  def build
    default_tabs.merge(conditional_tabs)
  end

  private

  attr_reader :authorization_request, :policy

  def authorizations_path
    authorization_request_authorizations_path(authorization_request)
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
    { authorization_request: summary_path }
  end

  def events_path
    authorization_request_events_path(authorization_request)
  end

  def france_connected_path
    authorization_request_france_connected_authorizations_path(authorization_request)
  end

  def messages_path
    authorization_request_messages_path(authorization_request)
  end

  def show_authorizations_tab?
    policy.authorizations? && authorization_request.authorizations.any?
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
    summary_authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id)
  end
end
