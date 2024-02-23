module AuthorizationRequestsFlashes
  def success_message_for_authorization_request(authorization_request, key:)
    message_for_authorization_request(authorization_request, key:, type: :success)
  end

  def error_message_for_authorization_request(authorization_request, key:)
    message_for_authorization_request(authorization_request, key:, type: :error)
  end

  private

  def message_for_authorization_request(authorization_request, key:, type:)
    reopening_prefix = authorization_request.reopening? ? 'reopening_' : ''

    public_send(:"#{type}_message", title: I18n.t!("#{key}.#{reopening_prefix}#{type}.title", name: authorization_request.name))
  end
end
