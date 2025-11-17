module WebhooksHelper
  def webhook_status_badge(webhook)
    if webhook.enabled && webhook.validated
      tag.span(t('developers.webhooks.index.active'), class: 'fr-badge fr-badge--success fr-badge--sm')
    elsif webhook.validated
      tag.span(t('developers.webhooks.index.inactive'), class: 'fr-badge fr-badge--warning fr-badge--sm')
    else
      tag.span(t('developers.webhooks.index.not_validated'), class: 'fr-badge fr-badge--error fr-badge--sm')
    end
  end
end
