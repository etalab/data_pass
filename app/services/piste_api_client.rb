# frozen_string_literal: true

require 'faraday'

class PISTEAPIClient
  class InvalidResponseError < StandardError; end

  OPEN_TIMEOUT_IN_SECONDS = 5
  TIMEOUT_IN_SECONDS = 120

  def self.create_subscription(authorization_request)
    new.create_subscription(authorization_request)
  end

  def create_subscription(authorization_request)
    response = connection.post(create_subscription_url) do |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.body = subscription_payload(authorization_request)
    end

    ensure_field_present!(response.body, 'piste_app_prd_link')
  end

  protected

  def subscription_payload(authorization_request)
    {
      requestor_email: authorization_request.contact_technique_email,
      approval_id: authorization_request.latest_authorization.id,
      api_name: Setting.fetch(:piste_api_name)
    }
  end

  def access_token
    response = connection.post(oauth_url) do |req|
      req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form(grant_type: 'client_credentials', scope: nil)
    end

    ensure_field_present!(response.body, 'access_token')['access_token']
  end

  def ensure_field_present!(body, field)
    return body if body.is_a?(Hash) && body[field].present?

    raise InvalidResponseError, "PISTE response without #{field} (#{describe_body(body)})"
  end

  def describe_body(body)
    return "keys: #{body.keys.join(', ')}, status: #{body['status'].inspect}" if body.is_a?(Hash)

    "body: #{body.to_s.truncate(200)}"
  end

  def connection
    @connection ||= Faraday.new do |conn|
      conn.request :json
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.options.open_timeout = OPEN_TIMEOUT_IN_SECONDS
      conn.options.timeout = TIMEOUT_IN_SECONDS
    end
  end

  def oauth_url
    Rails.application.credentials.piste_oauth_url
  end

  def create_subscription_url
    Rails.application.credentials.piste_create_subscription_url
  end

  def client_id
    Rails.application.credentials.piste_client_id
  end

  def client_secret
    Rails.application.credentials.piste_client_secret
  end
end
