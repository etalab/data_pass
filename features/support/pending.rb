Before do |scenario|
  next unless scenario.source_tag_names.include?('@Pending')

  pending
end
