puts "===BEGIN_OF_REPORT==="
puts "# ⚠️  Data Quality Warning"
puts ""
puts "2023-2024 data was migrated from DataPass v1 in early 2025."
puts "Event timestamps for these years were reconstructed and may not accurately"
puts "reflect actual user behavior (especially time-to-submit metrics)."
puts ""
puts "=" * 80
puts ""

[2025, 2024, 2023].each do |year|
  Stats::Report.new(date_input: year).print_report
  puts "\n"
  Stats::Report.new(date_input: year).print_time_to_submit_by_duration(step: :minute)
  puts "\n"
  Stats::Report.new(date_input: year).print_time_to_submit_by_duration(step: :hour)
  puts "\n"
  Stats::Report.new(date_input: year).print_time_to_submit_by_duration(step: :day)
  puts "\n"
end

puts "===END_OF_REPORT==="

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

