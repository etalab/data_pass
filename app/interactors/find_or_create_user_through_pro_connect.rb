class FindOrCreateUserThroughProConnect < ApplicationInteractor
  include ProConnectPayloads

  def call
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
    {
      'family_name' => info_payload['last_name'],
      'given_name' => info_payload['first_name'],
      'phone_number' => info_payload['phone'],
      'external_id' => raw_info_payload['sub'],
    }.merge(
      context.user_attributes || {}
    )
  end
end
