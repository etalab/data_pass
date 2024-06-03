module AuthorizationRequestsFlashes
  def success_message_for_authorization_request(authorization_request, key:)
    message_for_authorization_request(authorization_request, key:, type: :success)
  end

  def error_message_for_authorization_request(authorization_request, key:, include_model_errors: true)
    message_for_authorization_request(authorization_request, key:, type: :error, include_model_errors:)
  end

  private

  def message_for_authorization_request(authorization_request, key:, type:, include_model_errors: false)
    reopening_prefix = authorization_request.reopening? ? 'reopening_' : ''

    options = {
      title: I18n.t!("#{key}.#{reopening_prefix}#{type}.title", name: authorization_request.name),
    }

    if type == :error && include_model_errors
      options[:activemodel] = include_model_errors
      options[:description] = authorization_request.errors.full_messages
    end

    public_send(:"#{type}_message", **options)
  end
end
