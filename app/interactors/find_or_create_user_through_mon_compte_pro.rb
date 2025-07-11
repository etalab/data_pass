class FindOrCreateUserThroughMonComptePro < ApplicationInteractor
  include MonCompteProPayloads

  def call
    context.user = find_or_initialize_user
    context.user.assign_attributes(user_attributes)
    context.user.save
  end

  private

  def find_or_initialize_user
    User.where(
      email: info_payload['email'],
    ).first_or_initialize
  end

  def user_attributes
    info_payload.slice(
      'family_name',
      'given_name',
      'email_verified',
      'phone_number',
      'phone_number_verified',
    ).merge(
      'job_title' => info_payload['job'],
      'external_id' => info_payload['sub'],
    ).merge(
      context.user_attributes || {}
    )
  end
end
