class EmailVerifierJob < ApplicationJob
  attr_reader :email

  retry_on Emailable::TimeoutError, wait: :polynomially_longer, attempts: Float::INFINITY

  def perform(email)
    @email = email

    verified_email = VerifiedEmail.find_or_initialize_by(email:)

    return if verified_email.invalid?

    mark_email_as_safe!(verified_email) if email_safe?

    return if verified_email.whitelisted?
    return if verified_email.recent? && verified_email.determined?
    return if email_verifier_status == 'unknown'

    verified_email.assign_attributes(
      verified_at: Time.zone.now,
      status: email_verifier_status,
    )

    verified_email.save

    verified_email
  end

  private

  def mark_email_as_safe!(verified_email)
    verified_email.assign_attributes(
      verified_at: Time.zone.now,
      status: 'deliverable',
    )

    verified_email.save
  end

  def email_safe?
    user_exists_with_email? ||
      whitelisted_domain?
  end

  def email_verifier_status
    @email_verifier_status ||= EmailVerifierAPI.new(email).status
  end

  def user_exists_with_email?
    User.exists?(email:)
  end

  def whitelisted_domain?
    whitelisted_domain_for_emails.include?(email.split('@').last)
  end

  def whitelisted_domain_for_emails
    Rails.application.credentials.whitelisted_domain_for_emails || []
  end
end
