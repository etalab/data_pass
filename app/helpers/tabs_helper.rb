module TabsHelper
  def applicant_tabs_for(authorization_request)
    tabs = {}

    tabs[:authorization_request] = summary_authorization_request_form_path(
      form_uid: authorization_request.form_uid,
      id: authorization_request.id
    )

    tabs[:authorization_request_events] = authorization_request_events_path(authorization_request)
    tabs[:messages] = authorization_request_messages_path(authorization_request) if authorization_request.definition.feature?(:messaging)
    tabs[:authorizations] = authorization_request_authorizations_path(authorization_request) if authorization_request.authorizations.any?

    add_france_connected_authorizations_tab(tabs, authorization_request)

    tabs
  end

  def add_france_connected_authorizations_tab(tabs, authorization_request)
    return unless france_connect_with_linked_authorizations?(authorization_request)

    tabs[:france_connected_authorizations] = authorization_request_france_connected_authorizations_path(authorization_request)
  end

  def show_tabs_for_authorization_request?(authorization_request)
    return false if authorization_request.nil?
    return false if authorization_request.new_record?

    authorization_request.state != 'draft'
  end

  def authorization_tabs_for(authorization)
    tabs = {}

    tabs[:authorization] = authorization_path(authorization)
    tabs[:authorization_request_events] = authorization_events_path(authorization)
    tabs[:messages] = authorization_messages_path(authorization) if authorization.request.definition.feature?(:messaging)

    add_france_connected_authorizations_tab_for_authorization(tabs, authorization)

    tabs
  end

  def add_france_connected_authorizations_tab_for_authorization(tabs, authorization)
    return unless france_connect_with_linked_authorizations?(authorization.request)

    tabs[:france_connected_authorizations] = authorization_france_connected_authorizations_path(authorization)
  end

  def show_tabs_for_authorization?(authorization)
    return false if authorization.nil?

    true
  end

  private

  def france_connect_with_linked_authorizations?(authorization_request)
    authorization_request.definition.france_connect? &&
      authorization_request.france_connected_authorizations.exists?
  end
end
