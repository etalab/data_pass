return unless Rails.env.development?

seeds = Seeds.new
seeds.flushdb
seeds.perform
