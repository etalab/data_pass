require 'csv'

# Open and read the CSV file
csv_file_path = File.join(__dir__, 'ids_fichier_de_suivi.csv')

begin
  # Read the CSV file with headers
  csv_data = CSV.read(csv_file_path, headers: true)

  puts "Successfully loaded CSV file: #{csv_file_path}"


rescue CSV::MalformedCSVError => e
  puts "Error: Malformed CSV file - #{e.message}"
rescue Errno::ENOENT
  puts "Error: CSV file not found at #{csv_file_path}"
rescue => e
  puts "Error reading CSV file: #{e.message}"
end
