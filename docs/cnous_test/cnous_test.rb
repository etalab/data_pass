require 'net/http'
require 'base64'
require 'json'

COG_CODES = ['92040'].freeze # 92040 = Issy-les-moulineaux
MIN_SCHOLARSHIP_LEVEL = '0Bis' # available values are [0Bis, 1, 2, 3, 4, 5, 6, 7]
CAMPAIGN_YEAR = nil # Leave at null to get the current data

BASE_URL = 'http://api-pp.lescrous.fr/statut-boursier'
AUTH_URL = 'https://acces-pp.nuonet.fr/api-pp/oauth/token?grant_type=client_credentials'

def fetch_access_token
  client_id = ENV.fetch('CNOUS_CLIENT_ID')
  client_secret = ENV.fetch('CNOUS_CLIENT_SECRET')
  credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")

  uri = URI(AUTH_URL)
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/x-www-form-urlencoded'
  request['Accept'] = 'application/json'
  request['Authorization'] = "Basic #{credentials}"

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
  JSON.parse(response.body).fetch('access_token')
end

def create_export(access_token)
  uri = URI("#{BASE_URL}/v1/scholarship-holder-api-export/create")
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/json'
  request['Accept'] = 'application/json'
  request['Authorization'] = "Bearer #{access_token}"
  request.body = JSON.generate({
    cogCodes: COG_CODES,
    minScholarshipLevel: MIN_SCHOLARSHIP_LEVEL,
    campaignYear: CAMPAIGN_YEAR
  })

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
end

access_token = fetch_access_token
puts "Access token obtained."

begin
  response = create_export(access_token)
  body = JSON.parse(response.body)
  puts "Response (#{response.code}): #{JSON.pretty_generate(body)}"
  puts "Export ID: #{body['id']}"
rescue => e
  puts "Error: #{e.class} - #{e.message}"
end
