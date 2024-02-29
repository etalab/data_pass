namespace :db_seed do
  desc 'Seeds database in sandbox'

  task sandbox: :environment do
    return unless Rails.env.sandbox?

    original_delivery_method = ActionMailer::Base.delivery_method
    ActionMailer::Base.delivery_method = :test

    begin
      seeds = Seeds.new

      seeds.flushdb
      seeds.perform
    ensure
      ActionMailer::Base.delivery_method = original_delivery_method
    end
  end
end
