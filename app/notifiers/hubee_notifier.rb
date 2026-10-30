class HubEENotifier < BaseNotifier
  def approve(params)
    super

    return unless applicant_and_administrateur_metier_are_different?

    notification_policy.deliver('hubee_business_admin') { notify_administrateur_metier }
  end

  protected

  def kind
    fail NotImplementedError
  end

  private

  def applicant_and_administrateur_metier_are_different?
    authorization_request.applicant.email != authorization_request.administrateur_metier_email
  end

  def notify_administrateur_metier
    HubEEMailer.with(
      authorization_request:,
    ).administrateur_metier(kind).deliver_later
  end
end
