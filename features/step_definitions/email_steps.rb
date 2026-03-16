Before('@AvecCourriels') do
  ActionMailer::Base.deliveries.clear

  ActiveJob::Base.queue_adapter = :inline
end

After('@AvecCourriels') do
  ActiveJob::Base.queue_adapter = :test
end

Alors('un email est envoyé contenant {string}') do |content|
  matching = ActionMailer::Base.deliveries.find { |email| email_body_includes?(email, content) }

  expect(matching).to be_present
end

Alors('un email est envoyé contenant {string} à {string}') do |content, recipients|
  matching = ActionMailer::Base.deliveries.find { |email| email_body_includes?(email, content) }

  expect(matching).to be_present
  expect(matching.to).to eq(recipients.split('et').map(&:strip))
end

def email_body_includes?(email, content)
  email_bodies(email).any? { |body| body.include?(content) }
end

def email_bodies(email)
  return [email.body.decoded] unless email.multipart?

  [email.text_part, email.html_part].filter_map { |part| part&.body&.decoded }
end
