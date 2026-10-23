class APIErrorsFacade
  DEFAULT_STATUS = 422
  STATUS_OVERRIDES = { unauthorized_type: 403 }.freeze
  GENERIC_KEY = :generic
  POINTER_ROOTS = { data_keys: 'data', consent_keys: 'consentement' }.freeze

  attr_reader :status, :errors

  def self.from_interactor_result(result)
    new(result.error, authorization_request: result.authorization_request)
  end

  def initialize(error, authorization_request: nil)
    @authorization_request = authorization_request

    if known?(error)
      @status = STATUS_OVERRIDES.fetch(error[:key], DEFAULT_STATUS)
      @errors = format_errors(error)
    else
      @status = DEFAULT_STATUS
      @errors = [build_error(GENERIC_KEY)]
    end
  end

  private

  def known?(error)
    error && I18n.exists?("api_errors.#{error[:key]}.title")
  end

  def format_errors(error)
    key = error[:key]
    pointer_root = POINTER_ROOTS[error[:format]]

    return Array(error[:errors]).map { |name| keyed_error(key, name, pointer_root) } if pointer_root
    return model_errors(key) if attribute_errors?(key)

    message_errors(key, error[:errors])
  end

  def message_errors(key, messages)
    return [build_error(key)] if messages.blank?

    Array(messages).map { |message| build_error(key, detail: message) }
  end

  def build_error(key, detail: nil)
    {
      status: @status.to_s,
      title: translate(key, :title),
      detail: detail || translate(key, :detail)
    }
  end

  def keyed_error(key, name, pointer_root)
    {
      status: @status.to_s,
      title: translate(key, :title),
      detail: translate(key, :detail, key: name),
      source: { pointer: "/#{pointer_root}/#{name}" }
    }
  end

  def attribute_errors?(key)
    key == :authorization_request_invalid && @authorization_request&.errors&.any?
  end

  def model_errors(key)
    @authorization_request.errors.map { |model_error| attribute_error(key, model_error) }
  end

  def attribute_error(key, model_error)
    build_error(key, detail: model_error.full_message).tap do |error|
      error[:source] = { pointer: "/data/#{model_error.attribute}" } unless model_error.attribute == :base
    end
  end

  def translate(key, suffix, **interpolations)
    I18n.t("api_errors.#{key}.#{suffix}", **interpolations)
  end
end
