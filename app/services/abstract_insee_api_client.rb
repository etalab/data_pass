# frozen_string_literal: true

require 'faraday'

class AbstractINSEEAPIClient
  class UnavailableError < StandardError; end

  def self.calls_allowed?
    Setting.fetch(:insee_calls_enabled) && !INSEECallsPause.paused?
  end

  protected

  def http_connection(&block)
    @http_connection ||= Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json
      conn.options.timeout = 2
      yield(conn) if block
    end
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
