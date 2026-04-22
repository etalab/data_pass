class APIErrorsFacade
  DEFAULT_STATUS = 422
  STATUS_OVERRIDES = { unauthorized_type: 403 }.freeze
  GENERIC_KEY = :generic

  attr_reader :status, :errors

  def self.from_interactor_result(result)
    new(result.error)
  end

  def initialize(error)
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

    if error[:format] == :data_keys
      Array(error[:errors]).map { |data_key| data_key_error(key, data_key) }
    elsif error[:errors].present?
      Array(error[:errors]).map { |message| build_error(key, detail: message) }
    else
      [build_error(key)]
    end
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

  def translate(key, suffix, **interpolations)
    I18n.t("api_errors.#{key}.#{suffix}", **interpolations)
  end
end
