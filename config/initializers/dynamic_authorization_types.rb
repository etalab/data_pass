Rails.application.config.to_prepare do
  next unless defined?(AuthorizationDefinitionRecord) &&
              AuthorizationDefinitionRecord.table_exists? &&
              AuthorizationDefinitionRecord.any?

  AuthorizationDefinitionRecord.find_each { |record| DynamicAuthorizationTypeRegistrar.register(record) }
end
