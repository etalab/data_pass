module AuthorizationRequestsFlashes
  def success_message_for_authorization_request(authorization_request, key:, tiny: false)
    message_for_authorization_request(authorization_request, key:, type: :success, tiny:)
  end

  def error_message_for_authorization_request(authorization_request, key:, include_model_errors: true)
    message_for_authorization_request(authorization_request, key:, type: :error, include_model_errors:)
  end

  def set_aside_values_message(authorization_request, now: false)
    values = authorization_request.draft_set_aside_values
    model_class = (authorization_request.try(:object) || authorization_request).class
    fields = values.keys.map { |attribute| model_class.human_attribute_name(attribute) }.to_sentence

    (now ? flash.now : flash)[:warning] = {
      'title' => t('authorization_request_forms.draft_set_aside.title', count: values.size, fields:),
      'tiny' => true,
    }
  end

  private

  def message_for_authorization_request(authorization_request, key:, type:, include_model_errors: false, tiny: false)
    reopening_prefix = authorization_request.reopening? ? 'reopening_' : ''

    options = {
      title: t("#{key}.#{reopening_prefix}#{type}.title", name: authorization_request.name, default: t("#{key}.#{type}.title", name: authorization_request.name)),
    }

    options[:description] = t("#{key}.#{reopening_prefix}#{type}.description", name: authorization_request.name, default: t("#{key}.#{type}.description", name: authorization_request.name, default: nil))
    options[:errors] = authorization_request.errors.full_messages if type == :error && include_model_errors

    options[:tiny] = true if tiny

    public_send(:"#{type}_message", **options)
  end
end
