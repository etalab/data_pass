class FindOrCreateUserThroughProConnect < ApplicationInteractor
  include ProConnectPayloads

  def call
    context.user = find_or_initialize_user
    fail_with_error(:user_email_mismatch) if email_mismatch?
    context.user.assign_attributes(user_attributes)
    save_user
  end

  private

  def save_user
    context.user.save!
  rescue ActiveRecord::RecordInvalid
    fail_with_error(:user_invalid, errors: context.user.errors.full_messages)
  end

  def find_or_initialize_user
    find_by_sub || User.where(email: payload_email).first_or_initialize
  end

  def find_by_sub
    return if sub.blank?

    User.find_by(external_id: sub)
  end

  def sub
    raw_info_payload['sub']
  end

  def payload_email
    raw_info_payload['email'].downcase
  end

  def email_mismatch?
    sub.present? &&
      context.user.persisted? &&
      context.user.external_id == sub &&
      context.user.email.downcase != payload_email
  end

  def user_attributes
    identity_attributes
      .merge(sub_attributes)
      .merge(Hash(context.user_attributes))
  end

  def sub_attributes
    sub.present? ? { 'external_id' => sub } : {}
  end

  def identity_attributes
    {
      'family_name' => raw_info_payload['usual_name'],
      'given_name' => raw_info_payload['given_name'],
      'phone_number' => raw_info_payload['phone_number'],
    }.reject { |_attribute, value| value.to_s.blank? }
  end
end
