# Generate output filename with current date
output_dir = Rails.root.join('app', 'services', 'stats', 'results')
FileUtils.mkdir_p(output_dir)
output_file = output_dir.join("stats_#{Date.today}.md")

# Open file for writing
File.open(output_file, 'w') do |f|
  f.puts "# ⚠️  Data Quality Warning"
  f.puts ""
  f.puts "2023-2024 data was migrated from DataPass v1 in early 2025."
  f.puts "Event timestamps for these years were reconstructed and may not accurately"
  f.puts "reflect actual user behavior (especially time-to-submit metrics)."
  f.puts ""
  f.puts "=" * 80
  f.puts ""

  # Temporarily redirect stdout to the file
  original_stdout = $stdout
  $stdout = f

  [2025, 2024, 2023].each do |year|
    Stats::Report.new(date_input: year, provider: 'dinum').print_report
    puts "\n"
    Stats::Report.new(date_input: year, provider: 'dinum').print_time_to_submit_by_duration(step: :minute)
    puts "\n"
    Stats::Report.new(date_input: year, provider: 'dinum').print_time_to_first_instruction_by_duration(step: :day)
    puts "\n"
  end

  # Restore stdout
  $stdout = original_stdout
end

puts "Report successfully generated: #{output_file}"

# Stats::Report.new(date_input: 2025).print_time_to_submit_by_type_table

# Stats::Report.new(date_input: 2025).print_time_to_submit_by_duration(step: :day); puts 'ok'
# Stats::Report.new(date_input: 2025).print_time_to_submit_by_duration(step: :hour); puts 'ok'
# Stats::Report.new(date_input: 2025).print_time_to_submit_by_duration(step: :minute); puts 'ok'

# Stats::Report.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise', 'AuthorizationRequest::APIParticulier']).print_report; puts 'ok'
# Stats::Report.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise']).print_time_to_submit_by_duration(step: :day); puts 'ok'
# Stats::Report.new(date_input: 2025, authorization_types: ['AuthorizationRequest::APIEntreprise', 'AuthorizationRequest::APIParticulier']).print_time_to_submit_by_duration(step: :minute); puts 'ok'

# Stats::Report.new(date_input: 2025, provider: 'dinum').print_report; puts 'ok'
# Stats::Report.new(date_input: 2025, provider: 'dgfip').print_time_to_submit_by_duration(step: :day); puts 'ok'

# Stats::Report.new(date_input: 2025).print_volume_by_type; puts 'ok'
# Stats::Report.new(date_input: 2025).print_volume_by_provider; puts 'ok'
# Stats::Report.new(date_input: 2025, provider: 'dinum').print_volume_by_type; puts 'ok'

# Stats::Report.new(date_input: 2025).print_volume_by_type_with_states; puts 'ok'
# Stats::Report.new(date_input: 2025).print_volume_by_provider_with_states; puts 'ok'
# Stats::Report.new(date_input: 2025, provider: 'dinum').print_volume_by_type_with_states; puts 'ok'

