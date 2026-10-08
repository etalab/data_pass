class FindOrCreateUserThroughMonComptePro < ApplicationInteractor
  include MonCompteProPayloads

  def call
    context.user = find_or_initialize_user
    context.user.assign_attributes(user_attributes)
    context.user.save
  end

  private

  def find_or_initialize_user
    find_user_by_external_id ||
      find_or_initialize_user_by_email
  end

  def find_user_by_external_id
    User.where(
      external_id: info_payload['sub'],
    ).first
  end

  def find_or_initialize_user_by_email
    User.where(
      email: info_payload['email'],
    ).first_or_initialize
  end

  def user_attributes
    info_payload
      .slice('email', 'email_verified', 'phone_number_verified')
      .merge(identity_attributes)
      .merge('external_id' => info_payload['sub'])
      .merge(Hash(context.user_attributes))
  end

  def identity_attributes
    {
      'family_name' => info_payload['family_name'],
      'given_name' => info_payload['given_name'],
      'phone_number' => info_payload['phone_number'],
      'job_title' => info_payload['job'],
    }.reject { |_attribute, value| value.to_s.blank? }
  end
end
