class APIParticulierNotifier < APIEntreculierNotifier
  def approve(_params)
    notify_france_connect if authorization_request.with_france_connect?
    notify_formulaire_qf('approve') if authorization_request.with_formulaire_qf?

    super
  end

  private

  def notify_formulaire_qf(event_name)
    DeliverAuthorizationRequestWebhookJob.new(
      'formulaire_qf',
      webhook_payload(event_name),
      authorization_request.id,
    ).enqueue
  end
end
