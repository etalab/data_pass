class APIErrorsFacade
  DEFAULT_STATUS = 422
  STATUS_OVERRIDES = { unauthorized_type: 403, not_created_by_api: 403 }.freeze
  GENERIC_KEY = :generic

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
    names = Array(error[:errors])

    case error[:format]
    when :data_keys then names.map { |data_key| data_key_error(key, data_key) }
    when :consents then names.map { |consent| consent_error(key, consent) }
    else model_errors?(key) ? model_errors(key) : message_errors(key, names)
    end
  end

  def message_errors(key, messages)
    return [build_error(key)] if messages.blank?

    Array(messages).map { |message| build_error(key, detail: message) }
  end

  def model_errors?(key)
    key == :authorization_request_invalid && @authorization_request&.errors&.any?
  end

  def model_errors(key)
    @authorization_request.errors.map { |model_error| model_error_to_json(key, model_error) }
  end

  def model_error_to_json(key, model_error)
    error = build_error(key, detail: model_error.full_message)
    return error if model_error.attribute == :base

    error.merge(source: { pointer: "/data/#{model_error.attribute}" })
  end

  def build_error(key, detail: nil)
    {
      status: @status.to_s,
      title: translate(key, :title),
      detail: detail || translate(key, :detail)
    }
  end

  def data_key_error(key, data_key)
    {
      status: @status.to_s,
      title: translate(key, :title),
      detail: translate(key, :detail, key: data_key),
      source: { pointer: "/data/#{data_key}" }
    }
  end

  def consent_error(key, consent)
    {
      status: @status.to_s,
      title: translate(key, :title),
      detail: translate(key, :detail, key: consent),
      source: { pointer: "/consentement/#{consent}" }
    }
  end

  def translate(key, suffix, **interpolations)
    I18n.t("api_errors.#{key}.#{suffix}", **interpolations)
  end
end
