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

  def webhook_attempt_result_badge(webhook_attempt, size:)
    result, status = if webhook_attempt.abandoned?
                       %i[abandoned warning]
                     elsif webhook_attempt.success?
                       %i[success success]
                     else
                       %i[failure error]
                     end

    dsfr_badge(status:, size:) { t("developers.webhook_attempts.result_badge.#{result}") }
  end
end
