# frozen_string_literal: true

require 'faraday'

class AbstractINSEEAPIClient
  class UnavailableError < StandardError; end
  class InvalidResponseError < StandardError; end

  def self.calls_allowed?
    Setting.fetch(:insee_calls_enabled) && !INSEECallsPause.paused?
  end

  protected

  def http_connection(&block)
    @http_connection ||= Faraday.new do |conn|
      conn.request :retry, retry_options
      conn.response :raise_error
      conn.options.timeout = 2
      yield(conn) if block
    end
  end

  def retry_options
    {
      max: 2,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: [
        Faraday::ConnectionFailed,
        Faraday::TimeoutError,
      ],
    }
  end

  def ensure_insee_available!
    ensure_insee_calls_enabled!
    ensure_insee_calls_not_paused!
  end

  def ensure_insee_calls_enabled!
    return if Setting.fetch(:insee_calls_enabled)

    INSEECallsPause.record_skipped_call

    raise UnavailableError, 'INSEE calls are disabled by configuration'
  end

  def ensure_insee_calls_not_paused!
    return unless INSEECallsPause.paused?

    INSEECallsPause.record_skipped_call

    raise UnavailableError, 'INSEE calls are paused'
  end

  def pause_insee_calls!(error, message)
    INSEECallsPause.pause!
    Sentry.capture_exception(error)

    raise UnavailableError, "#{message}: #{error.message}"
  end
end
