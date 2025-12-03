require 'net/http'
require 'json'
require 'uri'
require 'fileutils'

API_BASE_URL = 'https://www.data.gouv.fr/api/1/dataservices/'
PAGE_SIZE = 100
OUTPUT_FILE = File.join(File.dirname(__FILE__), 'dataservices_with_api_gouv_access.json')

def fetch_dataservices(page: 1, page_size: PAGE_SIZE)
  uri = URI(API_BASE_URL)
  uri.query = URI.encode_www_form({ page: page, page_size: page_size })
  
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.read_timeout = 30
  
  request = Net::HTTP::Get.new(uri)
  request['Accept'] = 'application/json'
  
  retries = 0
  begin
    response = http.request(request)
    
    unless response.code == '200'
      puts "Error fetching dataservices: #{response.code} - #{response.body}"
      exit 1
    end
    
    JSON.parse(response.body)
  rescue => e
    retries += 1
    if retries < 5
      sleep 1
      retry
    else
      puts "Error fetching dataservices after 5 retries: #{e.message}"
      exit 1
    end
  end
end

def matches_pattern?(access_url)
  return false if access_url.nil? || access_url.empty?
  
  # Check if the URL contains api.gouv.fr and demande-acces
  access_url.include?('api.gouv.fr/') && access_url.include?('demande-acces')
end

puts "Fetching dataservices from data.gouv.fr..."
puts "Looking for dataservices with access links containing 'api.gouv.fr/<something>/demande-acces'"
puts "-" * 80

filtered_services = []
page = 1
total_fetched = 0

loop do
  data = fetch_dataservices(page: page, page_size: PAGE_SIZE)
  
  dataservices = data['data'] || []
  total_fetched += dataservices.size
  
  dataservices.each do |service|
    # The access/authorization URL is in authorization_request_url
    access_url = service['authorization_request_url'] || ''
    
    if matches_pattern?(access_url)
      filtered_services << {
        id: service['id'],
        title: service['title'],
        slug: service['slug'],
        access_url: access_url,
        url: service['self_web_url'] || "https://www.data.gouv.fr/fr/dataservices/#{service['slug']}/"
      }
    end
  end
  
  # Check if there are more pages
  if data['next_page'].nil? || data['next_page'].empty?
    break
  end
  
  page += 1
  print "."
  $stdout.flush
end

puts "\n\n" + "=" * 80
puts "Results: Found #{filtered_services.size} dataservice(s) matching the pattern"
puts "=" * 80

# Write results to JSON file
File.write(OUTPUT_FILE, JSON.pretty_generate(filtered_services))
puts "\nResults written to: #{OUTPUT_FILE}"

if filtered_services.empty?
  puts "\nNo dataservices found with access links containing 'api.gouv.fr/<something>/demande-acces'"
else
  puts "\nSummary:"
  filtered_services.each_with_index do |service, index|
    puts "#{index + 1}. #{service[:title]}"
  end
end

puts "\nTotal dataservices fetched: #{total_fetched}"
puts "Total matching: #{filtered_services.size}"

