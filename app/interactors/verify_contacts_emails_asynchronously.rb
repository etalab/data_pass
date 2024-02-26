class VerifyContactsEmailsAsynchronously < ApplicationInteractor
  def call
    contact_types.each do |contact_type|
      email = email_for(contact_type)

      next if email.blank?

      schedule_email_verifier_job(email)
    end
  end

  private

  def contact_types
    authorization_request.class.contact_types
  end

  def schedule_email_verifier_job(email)
    EmailVerifierJob.perform_later(email)
  end

  def email_for(contact_type)
    authorization_request.public_send(:"#{contact_type}_email")
  end

  def authorization_request
    context.authorization_request
  end
end
