class MigrateWebhooksFromCredentials < ActiveRecord::Migration[8.1]
  def up
    return unless Rails.application.credentials.webhooks

    migrate_webhook('api_entreprise', Webhook::VALID_EVENTS)
    migrate_webhook('api_particulier', Webhook::VALID_EVENTS)
    migrate_webhook('formulaire_qf', Webhook::VALID_EVENTS)
    migrate_webhook('annuaire_des_entreprises', ['approve'])
    migrate_webhook('france_connect', ['approve'])
  end

  def down; end

  private

  def migrate_webhook(authorization_definition_id, events)
    webhook_config = Rails.application.credentials.webhooks.public_send(authorization_definition_id.to_sym)
    return unless webhook_config&.url && webhook_config&.token

    Webhook.create!(
      authorization_definition_id: authorization_definition_id,
      url: webhook_config.url,
      secret: webhook_config.token,
      events: events,
      enabled: true,
      validated: true,
      activated_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error("Failed to migrate webhook for #{authorization_definition_id}: #{e.message}")
  end
end
