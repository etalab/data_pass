Before('@AvecCourriels') do
  ActionMailer::Base.deliveries.clear

  ActiveJob::Base.queue_adapter = :inline
end

After('@AvecCourriels') do
  ActiveJob::Base.queue_adapter = :test
end

Alors('un email est envoyé contenant {string}') do |content|
  last_email = ActionMailer::Base.deliveries.last

  expect(last_email).to be_present, "Aucun email n'a été envoyé"
  expect(last_email.body).to include(content)
end
