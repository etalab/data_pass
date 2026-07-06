class AutomatedEmailPreview::HubEEAdministrateurMetier < AutomatedEmailPreview
  def subject
    HubEEMailer.new.subject_for(automated_email.hubee_kind.to_sym)
  end

  private

  def body_template
    "hubee_mailer/administrateur_metier_#{automated_email.hubee_kind}"
  end
end
