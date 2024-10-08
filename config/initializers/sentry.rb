Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry_dsn
  config.breadcrumbs_logger = [:sentry_logger, :active_support_logger, :http_logger]
  config.enabled_environments = %w[staging production]

  config.traces_sample_rate = 1.0
end
