class BaseNotifier < ApplicationNotifier
  notifier_event_names.each do |event_name|
    define_method(event_name) do |_params|
      # Empty implementation, events are handled by default
    end
  end

  %w[
    request_changes
    refuse
  ].each do |event|
    define_method(event) do |params|
      email_notification_with_reopening(event, params)
    end
  end

  def approve(params)
    deliver_gdpr_emails

    notify_france_connect if authorization_request.with_france_connect?
    notify_dgfip_apim(params) if dgfip_provider?
    notify_hubee_formulaire_qf(params)

    return if notification_policy.suppress?('applicant_approval')

    email_notification_with_reopening('approve', params)
  end

  def submit(params)
    notify_instructors_individually('submit', params) unless notification_policy.suppress?('instructors_new_request')
    email_notification_with_reopening('submit', params) unless notification_policy.suppress?('applicant_submit_receipt')
  end

  def revoke(params)
    email_notification('revoke', params)
  end

  private

  def notify_france_connect
    return if notification_policy.suppress?('france_connect_team')

    FranceConnectMailer.with(authorization_request:).new_scopes.deliver_later
  end

  def notify_dgfip_apim(params)
    return if notification_policy.suppress?('dgfip_approval')

    DGFIP::APIMMailer.with(
      authorization: authorization_request.latest_authorization,
      reopening: params[:within_reopening]
    ).approve.deliver_later
  end

  def notify_hubee_formulaire_qf(params)
    return unless authorization_request.formulaire_qf?
    return if notification_policy.suppress?('hubee_qf_approval')
    return if params[:within_reopening] && formulaire_qf_before_reopening?

    HubEEMailer.with(authorization_request:).formulaire_qf_validation.deliver_later
  end

  def formulaire_qf_before_reopening?
    return true if authorization_before_reopening.nil?

    authorization_before_reopening.request_as_validated(load_documents: false).formulaire_qf?
  end

  def authorization_before_reopening
    @authorization_before_reopening ||= authorization_request.authorizations
      .where(authorization_request_class: authorization_request.class.name)
      .order(created_at: :desc)
      .offset(1)
      .first
  end

  def dgfip_provider?
    authorization_request.definition.provider.present? &&
      authorization_request.definition.provider.slug == 'dgfip'
  end
end
