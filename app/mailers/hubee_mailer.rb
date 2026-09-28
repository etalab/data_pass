class HubEEMailer < ApplicationMailer
  def administrateur_metier(kind)
    @authorization_request = params[:authorization_request]

    mail(
      to: @authorization_request.administrateur_metier_email,
      subject: subject_for(kind),
      template_name: "administrateur_metier_#{kind}"
    )
  end

  def formulaire_qf_validation
    @authorization_request = params[:authorization_request]
    return report_missing_formulaire_qf_recipients if formulaire_qf_recipients.blank?

    @editor = @authorization_request.editor
    @validated_at = formulaire_qf_validation_date

    mail(
      to: formulaire_qf_recipients,
      subject: t('.subject', authorization_request_id: @authorization_request.formatted_id, organization_name: @authorization_request.organization.name)
    )
  end

  def subject_for(kind)
    case kind
    when :cert_dc
      'Vous avez été désigné administrateur local HubEE pour une démarche CertDC'
    when :dila
      'Vous avez été désigné administrateur local HubEE pour des démarches service-public.fr'
    else
      raise "Unknown hubee email kind: #{kind}"
    end
  end

  private

  def formulaire_qf_recipients
    Array(params[:recipients].presence || Setting.fetch(:hubee_formulaire_qf_notification_emails)).compact_blank
  end

  def formulaire_qf_validation_date
    I18n.l((@authorization_request.last_validated_at || Time.zone.now).to_date, format: :long)
  end

  def report_missing_formulaire_qf_recipients
    return unless Rails.env.production?

    Sentry.capture_message(
      "HubEE formulaire QF notification skipped: no recipient configured for authorization_request ##{@authorization_request.id}",
      level: :warning
    )
  end
end
