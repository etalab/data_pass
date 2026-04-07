require 'net/http'
require 'base64'
require 'json'

BASE_URL = 'https://api-pp.nuonet.fr/statut-boursier'
AUTH_URL = 'https://acces-pp.nuonet.fr/api-pp/oauth/token?grant_type=client_credentials'

EXPORT_ID = ARGV[0] || abort('Usage: ruby cnous_download.rb <export_id>')

def fetch_access_token
  client_id = ENV.fetch('CNOUS_CLIENT_ID')
  client_secret = ENV.fetch('CNOUS_CLIENT_SECRET')
  credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")

  uri = URI(AUTH_URL)
  request = Net::HTTP::Post.new(uri)
  request['Content-Type'] = 'application/x-www-form-urlencoded'
  request['Accept'] = 'application/json'
  request['Authorization'] = "Basic #{credentials}"

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
  JSON.parse(response.body).fetch('access_token')
end

def download_export(access_token, export_id)
  uri = URI("#{BASE_URL}/v1/export/#{export_id}/download")
  request = Net::HTTP::Get.new(uri)
  request['Accept'] = 'application/json'
  request['Authorization'] = "Bearer #{access_token}"

  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
end

access_token = fetch_access_token
puts 'Access token obtained.'

response = download_export(access_token, EXPORT_ID)

case response.code
when '200'
  filename = "export_#{EXPORT_ID}.csv"
  File.write(filename, response.body)
  puts "File saved to #{filename}"
when '202'
  puts 'Export is still being generated, try again later.'
else
  puts "Error #{response.code}: #{response.body}"
end
