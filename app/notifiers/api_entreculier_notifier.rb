class APIEntreculierNotifier < BaseNotifier
  notifier_event_names.each do |event_name|
    define_method(event_name) do |_params|
      # Empty implementation, no email notifications for Entreculier
    end
  end

  def approve(_params)
    deliver_gdpr_emails

    RegisterOrganizationWithContactsOnCRMJob.perform_later(authorization_request.id)
  end

  def submit(_params)
    # Empty implementation, no email notifications for Entreculier
  end
end
