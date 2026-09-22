# frozen_string_literal: true

require 'faraday'

class AbstractINSEEAPIClient
  class UnavailableError < StandardError; end

  def self.calls_allowed?
    Setting.fetch(:insee_calls_enabled)
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
    return if self.class.calls_allowed?

    raise UnavailableError, 'INSEE calls are disabled by configuration'
  end
end
