module SqlQueryCounter
  def count_queries(pattern)
    matched = 0

    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      next if payload[:cached]

      matched += 1 if payload[:sql].match?(pattern)
    end

    yield

    matched
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end

RSpec.configure do |config|
  config.include SqlQueryCounter
end
