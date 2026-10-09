namespace :db_seed do
  desc 'Seeds database in sandbox'

  task sandbox: :environment do
    return unless Rails.env.sandbox?

    original_delivery_method = ActionMailer::Base.delivery_method
    original_queue_adapter = ActiveJob::Base.queue_adapter
    ActionMailer::Base.delivery_method = :test
    ActiveJob::Base.queue_adapter = :test

    begin
      seeds = Seeds.new

      seeds.flushdb
      seeds.perform
    ensure
      ActionMailer::Base.delivery_method = original_delivery_method
      ActiveJob::Base.queue_adapter = original_queue_adapter
    end
  end
end
