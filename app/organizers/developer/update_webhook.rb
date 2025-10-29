class Developer::UpdateWebhook < ApplicationOrganizer
  before do
    context.webhook_url_changed = context.webhook.url != context.webhook_params[:url]
  end

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call

      raise ActiveRecord::Rollback if changed_webhook_url_invalid?
    end

    context.fail!(error: :invalid_new_webhook_url) if changed_webhook_url_invalid?
  end

  organize Developer::DisableWebhook,
    Developer::UpdateWebhookModel,
    Developer::TestWebhookIfUrlChanged,
    Developer::MarkWebhookAsValidated

  def changed_webhook_url_invalid?
    context.webhook_url_changed && !context.webhook_test[:success]
  end
end
