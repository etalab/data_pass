require 'net/http'
require 'base64'
require 'json'

client_id = ENV.fetch('CNOUS_CLIENT_ID')
client_secret = ENV.fetch('CNOUS_CLIENT_SECRET')
credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")

uri = URI('https://acces-pp.nuonet.fr/api-pp/oauth/token?grant_type=client_credentials')

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/x-www-form-urlencoded'
request['Accept'] = 'application/json'
request['Authorization'] = "Basic #{credentials}"

response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  http.request(request)
end

access_token = JSON.pretty_generate(JSON.parse(response.body))["access_token"]

puts "Access token: #{access_token}"
