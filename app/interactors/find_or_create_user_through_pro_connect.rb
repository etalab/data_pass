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
      email: raw_info_payload['email'],
    ).first_or_initialize
  end

  def assign_attributes
    context.user.assign_attributes(user_attributes)
  end

  def user_attributes
    {
      'family_name' => raw_info_payload['usual_name'],
      'given_name' => raw_info_payload['given_name'],
      'phone_number' => raw_info_payload['phone_number'],
      'external_id' => raw_info_payload['sub'],
    }.merge(
      context.user_attributes || {}
    )
  end
end
