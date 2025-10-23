Before do |scenario|
  next unless scenario.source_tag_names.include?('@CreateDataProviders')

  Seeds.new.create_data_providers
end
