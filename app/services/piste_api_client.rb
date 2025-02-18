# frozen_string_literal: true

require 'faraday'

class PISTEAPIClient
  def create_subscription(authorization_request)
    response = Faraday.post(create_subscription_url) do |req|
      payload = {
        requestor_email: authorization_request.contact_technique_email,
        approval_id: authorization_request.latest_authorization.id,
        api_name: 'CaptchEtat v2'
      }
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Content-Type']  = 'application/json'
      req.body = payload.to_json
    end

    JSON.parse(response.body)
  end

  protected

  def access_token
    response = Faraday.post(oauth_url) do |req|
      req.headers['Authorization'] = "Basic #{Base64.strict_encode64("#{client_id}:#{client_secret}")}"
      req.headers['Content-Type']  = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form(grant_type: 'client_credentials', scope: nil)
    end

    JSON.parse(response.body)['access_token']
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
