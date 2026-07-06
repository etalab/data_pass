class AutomatedEmailPreview::GDPRContact < AutomatedEmailPreview
  def subject
    I18n.t(
      "gdpr_contact_mailer.#{recipient}.subject",
      authorization_request_contact_kind: I18n.t("authorization_request.contacts.#{recipient}"),
      authorization_request_name: sample_authorization_request.name,
    )
  end

  private

  def body_template
    "gdpr_contact_mailer/#{recipient}"
  end
end
