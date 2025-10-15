class FindOrCreateUserByEmail < ApplicationInteractor
  def call
    context.user = User.find_or_create_by(email: context.user_email) do |user|
      user.assign_attributes(Hash(context.user_attributes))
    end

    return if context.user.persisted?

    context.fail!(error: :user_invalid)
  end
end
