module AuthorizationRequestsFlashes
  def success_message_for_authorization_request(authorization_request, key:)
    message_for_authorization_request(authorization_request, key:, type: :success)
  end

  def success_message_for_building_authorization_request(authorization_request, key:)
    message_for_authorization_request(authorization_request, key:, type: :success, tiny: true)
  end

  def error_message_for_authorization_request(authorization_request, key:, include_model_errors: true)
    message_for_authorization_request(authorization_request, key:, type: :error, include_model_errors:)
  end

  private

  def message_for_authorization_request(authorization_request, key:, type:, include_model_errors: false, tiny: false)
    reopening_prefix = authorization_request.reopening? ? 'reopening_' : ''

    options = {
      title: t("#{key}.#{reopening_prefix}#{type}.title", name: authorization_request.name, default: t("#{key}.#{type}.title", name: authorization_request.name)),
    }

    if type == :error
      options[:description] = t("#{key}.#{reopening_prefix}#{type}.description", name: authorization_request.name, default: t("#{key}.#{type}.description", name: authorization_request.name, default: nil))
      options[:errors] = authorization_request.errors.full_messages if include_model_errors
    end

    options[:tiny] = true if tiny

    public_send(:"#{type}_message", **options)
  end
end
