Before do |scenario|
  next unless scenario.source_tag_names.include?('@FlushJobQueue')

  ActiveJob::Base.queue_adapter.enqueued_jobs = []
end
