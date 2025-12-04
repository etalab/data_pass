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

  # rubocop:disable Lint/UselessMethodDefinition
  def submit(_params)
    super
  end
  # rubocop:enable Lint/UselessMethodDefinition
end
