class EmailRecentlyVerifiedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    verified_email = VerifiedEmail.find_by(email: value)
    verified_email = create_or_refresh_verified_email!(value) if verified_email.blank? || verified_email.old?

    record.errors.add(attribute, :email_unreachable) if verified_email.unreachable?
  end

  private

  def create_or_refresh_verified_email!(email)
    EmailVerifierJob.new.perform(email)
  end
end
