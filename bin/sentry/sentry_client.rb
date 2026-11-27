require 'net/http'
require 'json'
require 'uri'

class SentryClient
  BASE_URI = ENV.fetch('SENTRY_URL', 'https://errors.data.gouv.fr').freeze
  ORG_SLUG = ENV.fetch('SENTRY_ORG', 'sentry').freeze
  DEFAULT_PROJECT = ENV.fetch('SENTRY_PROJECT', 'datapass-reborn').freeze
  TOKEN_FILE = '.sentry_token'.freeze

  attr_reader :project

  def initialize(project: DEFAULT_PROJECT)
    @project = project
    @token = load_token
  end

  def issues(query: 'is:unresolved', stats_period: '14d')
    get("/api/0/projects/#{ORG_SLUG}/#{@project}/issues/", statsPeriod: stats_period, query:)
  end

  def issue(issue_id)
    get("/api/0/issues/#{issue_id}/")
  end

  def latest_event(issue_id)
    get("/api/0/issues/#{issue_id}/events/latest/")
  end

  def events(issue_id, full: false)
    get("/api/0/issues/#{issue_id}/events/", full:)
  end

  private

  def get(path, params = {})
    uri = URI.join(BASE_URI, path)
    uri.query = URI.encode_www_form(params) unless params.empty?
    request = Net::HTTP::Get.new(uri, 'Authorization' => "Bearer #{@token}")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 30, read_timeout: 30) { |http| http.request(request) }
    abort "Sentry #{response.code} on #{path}: #{response.body.to_s[0, 300]}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def load_token
    path = [File.expand_path(TOKEN_FILE, Dir.pwd), File.expand_path("../../#{TOKEN_FILE}", __dir__)].find { |p| File.exist?(p) }
    abort "#{TOKEN_FILE} not found. Create a token at #{BASE_URI}/settings/account/api/auth-tokens/ (scopes: event:read, project:read) and run: echo \"token\" > #{TOKEN_FILE}" unless path

    File.read(path).strip
  end
end
