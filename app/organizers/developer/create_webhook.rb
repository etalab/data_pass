class Developer::CreateWebhook < ApplicationOrganizer
  organize Developer::CreateWebhookModel,
    Developer::TestWebhook,
    Developer::MarkWebhookAsValidated
end
