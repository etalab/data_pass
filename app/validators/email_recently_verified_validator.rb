class EmailRecentlyVerifiedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    create_or_refresh_verified_email!(value)

    verified_email = VerifiedEmail.find_by(email: value)

    if verified_email.blank?
      record.errors.add(attribute, :email_deliverability_unknown)

      track_errors_on_sentry(record, attribute, :email_deliverability_unknown)
    elsif verified_email.unreachable?
      record.errors.add(attribute, :email_unreachable)

      track_errors_on_sentry(record, attribute, :email_unreachable)
    end
  end

  private

  def create_or_refresh_verified_email!(email)
    EmailVerifierJob.new.perform(email)
  # rubocop:disable Lint/SuppressedException
  rescue EmailVerifierAPI::TimeoutError
  end
  # rubocop:enable Lint/SuppressedException

  def track_errors_on_sentry(record, attribute, error_type)
    Sentry.capture_message(
      'Fail to verify email deliverability',
      extra: {
        attribute:,
        record_id: record.id,
        record_type: record.class.name,
        error_type:,
      }
    )
  end
end
