class AuthorizationRequestPrefill
  SESSION_KEY = :authorization_request_prefill

  def initialize(session, authorization_request_form)
    @session = session
    @authorization_request_form = authorization_request_form
  end

  def capture(query_parameters)
    data = query_parameters.to_h.slice(*prefillable_attribute_names)

    data.present? ? store(data) : clear
  end

  def data
    stored['data'] if stored.present? && stored['form_uid'] == @authorization_request_form.id
  end

  def clear
    @session.delete(SESSION_KEY) if data
  end

  private

  def store(data)
    @session[SESSION_KEY] = { 'form_uid' => @authorization_request_form.id, 'data' => data }
  end

  def stored
    @session[SESSION_KEY]
  end

  def prefillable_attribute_names
    @authorization_request_form.authorization_request_class.prefillable_attribute_names
  end
end
