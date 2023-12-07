class FindOrCreateUser < ApplicationInteractor
  include MonCompteProPayloads

  def call
    context.user = find_or_initialize_user
    assign_attributes
    context.user.save!
  end

  private

  def find_or_initialize_user
    User.where(
      email: info_payload['email'],
      external_id: payload['uid'],
    ).first_or_initialize
  end

  def assign_attributes
    context.user.assign_attributes(user_attributes)
  end

  def user_attributes
    info_payload.slice(
      'family_name',
      'given_name',
      'email_verified'
    ).merge(
      'job_title' => info_payload['job']
    )
  end
end
