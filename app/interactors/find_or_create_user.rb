class FindOrCreateUser < ApplicationInteractor
  include MonCompteProPayloads

  def call
    context.fail! unless whitelisted?
    context.user = find_or_initialize_user
    assign_attributes
    context.user.save
  end

  private

  def find_or_initialize_user
    User.where(
      email: info_payload['email'],
    ).first_or_initialize
  end

  def assign_attributes
    context.user.assign_attributes(user_attributes)
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

  def whitelisted?
    Rails.env.sandbox? &&
      Rails.application.credentials.sandbox_whitelisted_emails.present? &&
      Rails.application.credentials.sandbox_whitelisted_emails.include?(info_payload['email'])
  end
end
