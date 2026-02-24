Rails.application.config.to_prepare do
  next unless defined?(HabilitationType) &&
              HabilitationType.table_exists? &&
              HabilitationType.any?

  HabilitationType.find_each { |record| DynamicAuthorizationRequestRegistrar.call(record) }
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  nil
end
