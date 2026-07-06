class BaseNotifier < ApplicationNotifier
  notifier_event_names.each do |event_name|
    define_method(event_name) do |_params|
      # Empty implementation, events are handled by default
    end
  end

  AuthorizationDefinition::AutomatedEmail::EVENTS.each do |event|
    define_method(event) do |params|
      deliver_automated_emails(event, params)
    end
  end

  private

  def deliver_automated_emails(event, params)
    authorization_request.definition.automated_emails
      .select { |automated_email| automated_email.event == event }
      .each { |automated_email| deliver_automated_email(automated_email, params) }
  end

  def deliver_automated_email(automated_email, params)
    case automated_email.recipient
    when 'applicant' then notify_applicant(automated_email.event, params)
    when 'instructors' then notify_instructors_individually(automated_email.event, params)
    when 'responsable_traitement', 'delegue_protection_donnees' then deliver_gdpr_email(automated_email.recipient)
    when 'france_connect' then notify_france_connect
    when 'dgfip_apim' then notify_dgfip_apim(params)
    when 'hubee_administrateur_metier' then notify_hubee_administrateur_metier(automated_email.hubee_kind)
    end
  end

  def notify_applicant(event, params)
    if event == 'revoke'
      email_notification(event, params)
    else
      email_notification_with_reopening(event, params)
    end
  end

  def notify_france_connect
    return unless authorization_request.with_france_connect?

    FranceConnectMailer.with(authorization_request:).new_scopes.deliver_later
  end

  def notify_dgfip_apim(params)
    DGFIP::APIMMailer.with(
      authorization: authorization_request.latest_authorization,
      reopening: params[:within_reopening]
    ).approve.deliver_later
  end

  def notify_hubee_administrateur_metier(kind)
    return if authorization_request.applicant.email == authorization_request.administrateur_metier_email

    HubEEMailer.with(
      authorization_request:,
    ).administrateur_metier(kind.to_sym).deliver_later
  end
end
