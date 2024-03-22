Before do |scenario|
  next unless scenario.source_tag_names.include?('@DeliverWebhook')

  ActiveJob::Base.queue_adapter.enqueued_jobs.delete_if do |j|
    j['job_class'] == 'DeliverAuthorizationRequestWebhookJob'
  end
end
