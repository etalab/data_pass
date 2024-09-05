Before('@AvecCourriels') do
  ActionMailer::Base.deliveries.clear

  ActiveJob::Base.queue_adapter = :inline
end

After('@AvecCourriels') do
  ActiveJob::Base.queue_adapter = :test
end

Alors('un email est envoyé contenant {string}') do |content|
  matching = ActionMailer::Base.deliveries.find { |email| email.body.include?(content) }

  expect(matching).to be_present
end

Alors('un email est envoyé contenant {string} à {string}') do |content, recipients|
  matching = ActionMailer::Base.deliveries.find { |email| email.body.include?(content) }

  expect(matching).to be_present
  expect(matching.to).to eq(recipients.split('et').map(&:strip))
end
