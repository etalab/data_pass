class APIEntreculierNotifier < BaseNotifier
  notifier_event_names.each do |event_name|
    define_method(event_name) do |_params|
      webhook_notification(event_name)
    end
  end

  def approve(_params)
    webhook_notification('approve')
    deliver_gdpr_emails

    RegisterOrganizationWithContactsOnCRMJob.perform_later(authorization_request.id)
  end

  def submit(_params)
    webhook_notification('submit')

    Instruction::AuthorizationRequestMailer.with(
      authorization_request:
    ).submit.deliver_later
  end
end
