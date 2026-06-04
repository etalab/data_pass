Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry_dsn
  config.breadcrumbs_logger = [:sentry_logger, :active_support_logger, :http_logger]
  config.enabled_environments = %w[staging production]

  config.traces_sample_rate = 1.0

  config.before_send_transaction = lambda do |event, _hint|
    event.spans&.reject! do |span|
      span[:op] == 'db.sql.active_record' &&
        span[:description].to_s.include?('rails_pulse_')
    end

    event
  end
end
