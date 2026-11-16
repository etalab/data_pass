Rails.application.config.x.public_rate_limit_store =
  if Rails.env.test?
    Rails.cache
  else
    ActiveSupport::Cache::RedisCacheStore.new(
      redis: -> { Kredis.configured_for(:shared) },
      namespace: 'public_rate_limit',
    )
  end
