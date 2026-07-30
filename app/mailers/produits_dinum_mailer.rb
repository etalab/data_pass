class ProduitsDinumMailer < ApplicationMailer
  def transmit_convention
    @authorization_request = params[:authorization_request]
    recipients = contacts_emails
    return if recipients.blank?

    @convention_url = convention_url
    @demande_date = demande_date

    mail(
      bcc: recipients,
      subject: t('.subject', authorization_request_id: @authorization_request.formatted_id),
    )
  end

  private

  def contacts_emails
    %i[responsable_traitement delegue_protection_donnees contact_technique]
      .map { |contact| @authorization_request.public_send(:"#{contact}_email") }
      .compact_blank
  end

  def convention_url
    "#{root_url}conventions/convention_mise_a_disposition_produits_dinum.pdf"
  end

  def demande_date
    date = @authorization_request.last_submitted_at || @authorization_request.created_at
    I18n.l(date.to_date, format: :long)
  end
end
