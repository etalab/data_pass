class EmailRecentlyVerifiedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    create_or_refresh_verified_email!(value)

    verified_email = VerifiedEmail.find_by(email: value)

    if verified_email.blank?
      record.errors.add(attribute, :email_deliverability_unknown)
    elsif verified_email.unreachable?
      record.errors.add(attribute, :email_unreachable)
    end
  end

  private

  def create_or_refresh_verified_email!(email)
    EmailVerifierJob.new.perform(email)
  end
end
