require 'singleton'

class Http
  include Singleton

  def request(http_verb, options = {})
    url = options.fetch(:url)
    default_auth_header = 'Authorization'
    auth_header = options.fetch(:auth_header, default_auth_header)
    auth_method = if auth_header == default_auth_header
                    options.fetch(:use_basic_auth_method, false) ? 'Basic ' : 'Bearer '
                  else
                    ''
                  end
    use_form_content_type = options.fetch(:use_form_content_type, false)
    api_key = options.fetch(:api_key, '') || ''
    body = options.fetch(:body, {})
    tag = options.fetch(:tag)
    timeout = options.fetch(:timeout, 30)

    http = Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json
      conn.options.timeout = timeout
    end

    http_with_auth =
      (http.request :authorization, auth_header, -> { "#{auth_method}#{api_key}" } unless api_key.empty?)

    response = if body.empty?
                 http_with_auth
                   .send(http_verb, url)
               elsif use_form_content_type
                 http_with_auth
                   .send(http_verb, url, form: body)
               else
                 http_with_auth
                   .send(http_verb, url)
               end

    unless response.status.success?
      raise ApplicationController::BadGateway.new(
        tag,
        url,
        response.code,
        response.to_s
      )
    end

    response
    # rescue HTTP::Error => e
    #   raise ApplicationController::BadGateway.new(
    #     tag,
    #     url,
    #     nil,
    #     nil
    #   ), e.message
    # rescue OpenSSL::SSL::SSLError => e
    #   raise ApplicationController::BadGateway.new(
    #     tag,
    #     url,
    #     nil,
    #     nil
    #   ), e.message
  end

  def get(options)
    request(:get, options)
  end

  def post(options)
    request(:post, options)
  end

  def patch(options)
    request(:patch, options)
  end
end
